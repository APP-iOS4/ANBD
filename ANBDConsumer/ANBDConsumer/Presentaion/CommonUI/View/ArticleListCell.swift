//
//  ArticleListCell.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

struct ArticleListCell: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    enum ListCellValue {
        case article(Article)
        case trade(Trade)
    }
    
    @State private var thumbnailImageURL: URL?
    @State private var thumbnailImageData: Data?
    @State private var isLiked: Bool = false
    
    var value: ListCellValue
    
    var body: some View {
        
        switch value {
        case .article(let article):
            if #available(iOS 17.0, *) {
                articleListCell(article)
                    .onChange(of: networkMonitor.isConnected) {
                        if networkMonitor.isConnected {
                            Task {
                                do {
                                    let url = await articleViewModel.loadCellImageURL(article: article, path: article.thumbnailImagePath)
                                    thumbnailImageURL = url
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
            } else {
                articleListCell(article)
                    .onChange(of: networkMonitor.isConnected) { _ in
                        if networkMonitor.isConnected {
                            Task {
                                do {
                                    let url = await articleViewModel.loadCellImageURL(article: article, path: article.thumbnailImagePath)
                                    thumbnailImageURL = url
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
            }
            
        case .trade(let trade):
            if #available(iOS 17.0, *) {
                tradeListCell(trade)
                    .onChange(of: networkMonitor.isConnected) {
                        if networkMonitor.isConnected {
                            Task {
                                do {
                                    let image = try await StorageManager.shared.downloadImage(
                                        path: .trade,
                                        containerID: "\(trade.id)/thumbnail",
                                        imagePath: trade.thumbnailImagePath
                                    )
                                    thumbnailImageData = image
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
            } else {
                tradeListCell(trade)
                    .onChange(of: networkMonitor.isConnected) { _ in
                        if networkMonitor.isConnected {
                            Task {
                                do {
                                    let image = try await StorageManager.shared.downloadImage(
                                        path: .trade,
                                        containerID: "\(trade.id)/thumbnail",
                                        imagePath: trade.thumbnailImagePath
                                    )
                                    thumbnailImageData = image
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
            }
        }
    }
    
    fileprivate func tradeListCell(_ trade: Trade) -> some View {
         HStack(alignment: .top) {
             
             if let thumbnailImageData {
                 if let uiImage = UIImage(data: thumbnailImageData) {
                     Image(uiImage: uiImage)
                         .resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(width: 100, height: 100)
                         .clipShape(RoundedRectangle(cornerRadius: 10))
                         .padding(.trailing, 10)
                 }
             } else {
                 ProgressView()
                     .frame(width: 100, height: 100)
                     .clipShape(RoundedRectangle(cornerRadius: 10))
                     .padding(.trailing, 10)
             }
             
             VStack(alignment: .leading, spacing: 5) {
                 HStack {
                     Text("\(trade.title)")
                         .font(ANBDFont.SubTitle1)
                         .foregroundStyle(.gray900)
                         .lineLimit(2)
                         .multilineTextAlignment(.leading)
                     
                     Spacer()
                     
                     if trade.tradeState == .finish {
                         RoundedRectangle(cornerRadius: 5)
                             .foregroundColor(.gray800)
                             .frame(width: 65, height: 38)
                             .overlay {
                                 Text("\(trade.tradeState.description)")
                                     .font(ANBDFont.body2)
                                     .frame(maxWidth: 65, maxHeight: 38)
                                     .foregroundStyle(.gray50)
                             }
                     }
                 }
                 
                 HStack {
                     Text("\(trade.location.description)")
                     
                     Text("・")
                         .padding(.leading, -5)
                     
                     Text("\(trade.createdAt.relativeTimeNamed)")
                         .padding(.leading, -5)
                     Spacer()
                 }
                 .lineLimit(1)
                 .font(ANBDFont.Caption3)
                 .foregroundStyle(.gray400)
                 Spacer(minLength: 0)
                 
                 HStack {
                     
                     Spacer()
             
                     Image(systemName: isLiked ? "heart.fill" : "heart")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 20)
                         .foregroundStyle(isLiked ? .heartRed : .gray800)
                         .onTapGesture {
                             Task {
                                 await tradeViewModel.updateLikeTrade(trade: trade)
                             }
                             isLiked.toggle()
                         }
                         .padding(.leading, 10)
                 }
                 .foregroundStyle(.gray800)
             }
         }
         .frame(height: 100)
         .onAppear {
             isLiked = UserStore.shared.user.likeTrades.contains(trade.id)
             Task {
                 do {
                     let image = try await StorageManager.shared.downloadImage(
                         path: .trade,
                         containerID: "\(trade.id)/thumbnail",
                         imagePath: trade.thumbnailImagePath
                     )
                     thumbnailImageData = image
                 } catch {
                     print(error.localizedDescription)
                 }
             }
         }
     }
    
    fileprivate func articleListCell(_ article: Article) -> some View {
        HStack(alignment: .top) {
            if let thumbnailImageURL {
                    KFImage(thumbnailImageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 10)
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 10)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(article.title)")
                    .font(ANBDFont.SubTitle1)
                    .foregroundStyle(.gray900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(article.writerNickname)")
                    Text("・")
                        .padding(.leading, -5)
                    Text("\(article.createdAt.relativeTimeNamed)")
                        .padding(.leading, -5)
                    Spacer()
                }
                .lineLimit(1)
                .font(ANBDFont.Caption3)
                .foregroundStyle(.gray400)
                Spacer(minLength: 0)
                
                HStack {
                    Spacer()
                    
                    Image(systemName: "hand.thumbsup")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text("\(article.likeCount)")
                        .font(.system(size: 12))
                        .padding(.trailing, 10)
                        .padding(.top, 2)
                    
                    Image(systemName: "text.bubble")
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Text("\(article.commentCount)")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                }
                .foregroundStyle(.gray800)
            }
        }
        .frame(height: 100)
        .onAppear {
            Task {
                do {
                    let url = await articleViewModel.loadCellImageURL(article: article, path: article.thumbnailImagePath)
                    thumbnailImageURL = url
                } catch {
                    
                }
            }
        }
    }
}

#Preview {
    ArticleListCell(value: .article(Article(writerID: "id", writerNickname: "코딩신", category: .accua, title: "코딩 잘하는 꿀팁~", content: "아몰랑", thumbnailImagePath: "")))
}
