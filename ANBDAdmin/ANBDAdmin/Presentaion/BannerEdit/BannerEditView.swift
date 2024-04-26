//
//  BannerEditView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/16/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

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
                                Spacer()
                                if let imageUrl = URL(string: banner.thumbnailImageURLString) {
                                    KFImage(imageUrl)
                                        .placeholder {
                                            ProgressView()
                                        }
                                        .resizable()
                                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 660, height: 220)))
                                        .fade(duration: 1)
                                        .onFailure { e in
                                            print("Job failed: \(e.localizedDescription)")
                                        }
                                        .resizable()
                                        .frame(minWidth: 220, maxHeight: 73)
                                        
                                }
                                Spacer()
                            }
                            .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                            .padding()
                            Divider()
                            VStack(alignment: .leading) {
                                Text("배너 ID")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(banner.id)")
                                Spacer()
                            }
                            .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                            .padding()
                            Divider()
                            VStack(alignment: .leading) {
                                Text("생성일자")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(DateFormatterSingleton.shared.dateFormatter(banner.createdAt))")
                                Spacer()
                            }
                            .padding()
                            .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
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
                    VStack{
                        Image("BannerGuideImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 600, height: 200)
                        
                    }
                    .padding(.bottom, 30)
                    TextField("배너 썸네일 URL 입력란, 이미지 비율은 3:1 비율입니다.", text: $newBannerThumbnailURL)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    TextField("배너 URL 입력란", text: $newBannerURL)
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
