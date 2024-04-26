//
//  BannerEditDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/16/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

struct BannerEditDetailView: View {
    @Environment(\.presentationMode) var bannerDeletePresentationMode
    let banner: Banner
    let bannerUsecase = DefaultBannerUsecase()
    @Binding var deletedBannerID: String?
    @State private var bannerDeleteShowingAlert = false
    
    var body: some View {
        List {
            Text("배너 링크:").foregroundColor(.gray) + Text(" \(banner.urlString)")
            if let imageUrl = URL(string: banner.thumbnailImageURLString) {
                Text("썸네일:").foregroundColor(.gray)
                Text("썸네일:").foregroundColor(.gray)
                KFImage(imageUrl)
                    .placeholder {
                        ProgressView()
                    }
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 660, height: 220)))
                    .fade(duration: 1)
                    .onFailure { e in
                        print("Job failed: \(e.localizedDescription)")
                    }
            }
            HStack {
                Text("배너 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(banner.id)")
            }
            HStack {
                Text("생성일자:").foregroundColor(.gray)
                Spacer()
                Text(" \(DateFormatterSingleton.shared.dateFormatter(banner.createdAt))")
            }
        }
        .navigationBarTitle(banner.id)
        .toolbar {
            Button("삭제") {
                bannerDeleteShowingAlert = true // 경고를 표시
            }
        }
        .alert(isPresented: $bannerDeleteShowingAlert) { // 경고를 표시
            Alert(
                title: Text("삭제"),
                message: Text("해당 배너를 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    Task {
                        do {
                            try await bannerUsecase.deleteBanner(bannerID: banner.id)
                            deletedBannerID = banner.id
                            bannerDeletePresentationMode.wrappedValue.dismiss()
                        } catch {
                            print("배너를 삭제하는데 실패했습니다: \(error)")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
