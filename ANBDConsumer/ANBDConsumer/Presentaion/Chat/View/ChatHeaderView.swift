//
//  ChatHeaderView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/19/24.
//

import SwiftUI
import ANBDModel
import SkeletonUI

struct ChatHeaderView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    var trade: Trade?
    @State var imageData: Data?
    
    @State private var isLoading: Bool = true
    
//    @Binding var tradeState: TradeState
    @Binding var isShowingStateChangeCustomAlert: Bool
    
    var body: some View {
        Button(action: {
            if trade != nil {
                switch coordinator.selectedTab {
                case .home, .article, .trade, .mypage:
                    coordinator.pop()
                case .chat:
                    Task {
                        guard let trade = chatViewModel.selectedTrade else { return }
                        tradeViewModel.getOneTrade(trade: trade)
                        coordinator.trade = trade
                        coordinator.chatPath.append(Page.tradeDetailView)
                    }
                }
            }
        }, label: {
            HStack {
                ZStack {
                    if trade == nil {
                        Image(systemName: "exclamationmark.square.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .padding(.trailing, 10)
                            .foregroundStyle(.gray500)
                    }
                    Color.clear
                        .skeleton(with: isLoading , shape: .rectangle)
                        .frame(width: 75, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 10)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.isLoading = false
                            }
                        }
                    
                    if let imageData {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.trailing, 10)
                                .onAppear {
                                    isLoading = false
                                }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(trade == nil ? "삭제된 게시물" : trade?.title ?? "Unknown")
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .font(ANBDFont.SubTitle3)
                            .skeleton(with: isLoading,size: CGSize(width: 150, height: 15))
                        
                        Spacer()
                        
                        if let trade {
                            if trade.writerID == chatViewModel.user.id {
                                TradeStateChangeView(tradeState: trade.tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert)
                                    .padding(.trailing, 10)
                                    .skeleton(with: isLoading,size: CGSize(width: 50, height: 20))
                            }
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Text(tradeProductString)
                        .foregroundStyle(.gray400)
                        .font(ANBDFont.Caption3)
                        .skeleton(with: isLoading,size: CGSize(width: 200, height: 12))
                }
                .padding(.vertical)
            }
            .foregroundStyle(.gray900)
        })
        .onAppear {
            if let trade {
                Task {
                    imageData = try await chatViewModel.loadThumnailImage(containerID: trade.id, imagePath: trade.thumbnailImagePath)
                }
            }
        }
        .disabled(trade == nil)
    }

    
    /// Trade 상품 String
    private var tradeProductString: String {
        if trade == nil {
            return "글쓴이가 삭제한 게시물이에요."
        } else {
            if let trade {
                if trade.category == .nanua {
                    return trade.myProduct
                } else if trade.category == .baccua {
                    return "\(trade.myProduct) ↔ \(trade.wantProduct ?? "제시")"
                }
            }
            return ""
        }
    }
}

