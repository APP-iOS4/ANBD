//
//  BannerEditView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/16/24.
//

import SwiftUI
import ANBDModel
import CachedAsyncImage

struct BannerEditView: View {
    @StateObject private var bannerEditViewModel = BannerEditViewModel()
    @State private var bannerEditShowingAlert = false // 경고 표시 상태를 추적 변수
    @State private var showingAddBannerSheet = false // 배너 추가 Sheet 표시 상태를 추적 변수
    @State private var newBannerURL = "" // 새 배너 URL을 추적하는 변수
    @State private var newBannerThumbnailURL = "" // 새 배너 썸네일 URL을 추적하는 변수
    
    var body: some View {
        VStack {
            List {
                ForEach(bannerEditViewModel.bannerList, id: \.id) { banner in
                    NavigationLink(destination: BannerEditDetailView(banner: banner, deletedBannerID: $bannerEditViewModel.deletedBannerID)) {
                        HStack{
                            VStack(alignment: .leading) {
                                Text("썸네일 이미지")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                if let imageUrl = URL(string: banner.thumbnailImageURLString) {
                                    CachedAsyncImage(url: imageUrl) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 250)
                                        case .failure:
                                            Text("Failed to load image")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                            .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("배너 ID")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(banner.id)")
                            }
                            .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                            .padding()
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("생성일자")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(dateFormatter(banner.createdAt))")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
                bannerEditViewModel.loadBanners()
            }
            .navigationBarTitle("배너 목록")
            .toolbar {
                Button("배너 추가") {
                    showingAddBannerSheet = true // 배너 추가 Sheet를 표시
                }
            }
            .sheet(isPresented: $showingAddBannerSheet) {
                VStack {
                    TextField("배너 URL", text: $newBannerURL)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    TextField("배너 썸네일 URL", text: $newBannerThumbnailURL)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .padding(.vertical, 30)
                    Button("배너 추가하기") {
                        Task {
                            await bannerEditViewModel.addBanner(urlString: newBannerURL, thumbnailImageURLString: newBannerThumbnailURL)
                            showingAddBannerSheet = false // 배너 추가 Sheet를 숨김
                        }
                    }
                }
                .padding()
            }
        }
    }
}
