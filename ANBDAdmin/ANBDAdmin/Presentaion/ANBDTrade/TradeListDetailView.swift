//
//  SwiftUIView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/11/24.
//

import SwiftUI
import ANBDModel
import FirebaseStorage
import CachedAsyncImage

struct TradeListDetailView: View {
    @Environment(\.presentationMode) var tradepresentationMode
    let trade: Trade
    let tradeUsecase = DefaultTradeUsecase()
    @Binding var deletedTradeID: String?
    @State private var tradeDeleteShowingAlert = false
    @State private var tradeImageUrls:[URL?] = []


    var body: some View {
        List {
            Text("이미지:").foregroundColor(.gray)
            ForEach(tradeImageUrls.indices, id: \.self) { index in
                            if let url = tradeImageUrls[index] {
                                CachedAsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                ProgressView()
                            }
                        }
            Text("이미지 ID:").foregroundColor(.gray) + Text(" \(trade.imagePaths )")
            Text("제목:").foregroundColor(.gray) + Text(" \(trade.title)")
            Text("게시물ID:").foregroundColor(.gray) + Text(" \(trade.id)")
            Text("작성자 닉네임:").foregroundColor(.gray) + Text(" \(trade.writerNickname)")
            Text("작성자 ID:").foregroundColor(.gray) + Text(" \(trade.writerID)")
            Text("생성일자:").foregroundColor(.gray) + Text(" \(dateFormatter(trade.createdAt))")
            Text("카테고리:").foregroundColor(.gray) + Text(" \(trade.category)")
            Text("내 물건:").foregroundColor(.gray) + Text(" \(trade.myProduct)")
            Text("바꾸고 싶은 물건:").foregroundColor(.gray) + Text(" \(String(describing: trade.wantProduct))")
            Text("내용:").foregroundColor(.gray) + Text(" \(trade.content)")
            
        }
        .onAppear {
                    tradeLoadImages()
                }
        .navigationBarTitle(trade.title)
        .toolbar {
                    Button("Delete") {
                        tradeDeleteShowingAlert = true // 경고를 표시
                    }
                }
                .alert(isPresented: $tradeDeleteShowingAlert) { // 경고를 표시
                    Alert(
                        title: Text("Delete"),
                        message: Text("Are you sure you want to delete this trade?"),
                        primaryButton: .destructive(Text("Delete")) {
                            Task {
                                do {
                                    try await tradeUsecase.deleteTrade(trade: trade)
                                    deletedTradeID = trade.id
                                    tradepresentationMode.wrappedValue.dismiss()
                                } catch {
                                    print("게시물을 삭제하는데 실패했습니다: \(error)")
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
    }
    func tradeLoadImages() {
            let storage = Storage.storage()
            let storageRef = storage.reference()

            for path in trade.imagePaths {
                let fullPath = "Trade/\(trade.id)/\(path)"
                let imageRef = storageRef.child(fullPath)
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error downloading image URL: \(error)")
                    } else {
                        tradeImageUrls.append(url)
                    }
                }
            }
        }
}

