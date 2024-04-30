//
//  TradeDetailView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

struct TradeDetailView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var coordinator: Coordinator

    @State var trade: Trade
    
    @State private var isShowingCreat: Bool = false
    @State private var isGoingToProfileView: Bool = false
    @State private var isShowingConfirm: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingStateChangeCustomAlert: Bool = false
    @State private var isShowingDeleteCustomAlert: Bool = false
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var idx: Int = 0
    
    @State private var writerUser: User?
    @State private var user = UserStore.shared.user
    
    @State private var isLiked: Bool = false
    @State private var isMine: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        //이미지
                        TabView(selection: $idx) {
                            ForEach(0..<tradeViewModel.detailImages.count, id: \.self) { i in
                                if let image = UIImage(data: imageData[i]) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .onTapGesture {
                                            isShowingImageDetailView.toggle()
                                            idx = i
                                        }
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
                        
                        //작성자 이미지, 닉네임, 작성시간
                        HStack {
                            if let writerUser {
                                KFImage(URL(string: writerUser.profileImage))
                                    .placeholder({ _ in
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                    })
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        coordinator.user = writerUser
                                        switch coordinator.selectedTab {
                                        case .home, .article, .trade, .chat:
                                            if coordinator.isFromUserPage {
                                                coordinator.pop(2)
                                            } else {
                                                coordinator.appendPath(.userPageView)
                                            }
                                            coordinator.isFromUserPage.toggle()
                                        case .mypage:
                                            coordinator.pop(coordinator.mypagePath.count)
                                        }
                                    }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(tradeViewModel.trade.writerNickname)")
                                    .font(ANBDFont.SubTitle1)
                                    .foregroundStyle(.gray900)
                                
                                Text("\(tradeViewModel.trade.createdAt.relativeTimeNamed)")
                                    .font(ANBDFont.body2)
                                    .foregroundStyle(.gray600)
                            }
                            
                            Spacer()
                            
                            if user.id == tradeViewModel.trade.writerID {
                                TradeStateChangeView(tradeState: tradeViewModel.trade.tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert, fontSize: 17)
                            }
                            
                        }//HStack
                        .padding(5)
                        .padding(.horizontal, 5)
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("\(tradeViewModel.trade.title)")
                                .font(ANBDFont.Heading3)
                                .foregroundStyle(.gray900)
                                .fontWeight(.bold)
                                .padding(.bottom, 1)
                            Text("\(tradeViewModel.trade.itemCategory.rawValue) · \(tradeViewModel.trade.location.description)")
                                .font(ANBDFont.pretendardMedium(13))
                                .foregroundStyle(.gray500)
                                .padding(.bottom)
                            
                            Text("\(tradeViewModel.trade.content)")
                                .font(ANBDFont.body1)
                                .foregroundStyle(.gray900)
                        }//VStack
                        .padding()
                    }//VStack
                }//ScrollView
                
                Divider()
                bottomView
            }//VStack
            if isShowingStateChangeCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingStateChangeCustomAlert, viewType: .changeState) {
                    Task {
                        print("상태 변경!")
                        await tradeViewModel.updateState(trade: tradeViewModel.trade)
                    }
                }
            }
            if isShowingDeleteCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingDeleteCustomAlert, viewType: .tradeDelete) {
                    Task {
                        print("삭제!")
                        await tradeViewModel.deleteTrade(trade: tradeViewModel.trade)
                        await tradeViewModel.reloadFilteredTrades(category: trade.category)
                        self.dismiss()
                    }
                }
            }
            
            /// 토스트 뷰
            if coordinator.isShowingToastView {
                VStack {
                    CustomToastView()
                    
                    Spacer()
                }
            }
        }//ZStack
        .onAppear {
            tradeViewModel.getOneTrade(trade: trade)
            isLiked = user.likeTrades.contains(tradeViewModel.trade.id)
            Task {
                writerUser = await myPageViewModel.getUserInfo(userID: tradeViewModel.trade.writerID)
                tradeViewModel.detailImages = try await tradeViewModel.loadDetailImages(path: .trade, containerID: tradeViewModel.trade.id, imagePath: tradeViewModel.trade.imagePaths)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(isPresented: $isShowingCreat, onDismiss: {
            
        }) {
            TradeCreateView(isShowingCreate: $isShowingCreat, isNewProduct: false, trade: tradeViewModel.trade)
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(isShowingImageDetailView: $isShowingImageDetailView, images: $imageData, idx: $idx)
        }
        .navigationTitle("나눔 · 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if user.id != tradeViewModel.trade.writerID {
                        Button(role: .destructive) {
                            coordinator.reportType = .trade
                            coordinator.reportedObjectID = trade.id
                            coordinator.appendPath(.reportView)
                        } label: {
                            Label("신고하기", systemImage: "exclamationmark.bubble")
                        }
                    } else {
                        Button {
                            isShowingCreat.toggle()
                            tradeViewModel.selectedLocation = tradeViewModel.trade.location
                            tradeViewModel.selectedItemCategory = tradeViewModel.trade.itemCategory
                        } label: {
                            Label("수정하기", systemImage: "square.and.pencil")
                        }
                        Button(role: .destructive) {
                            isShowingDeleteCustomAlert.toggle()
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(ANBDFont.pretendardRegular(12))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                }
            }
        }
    }
}

extension TradeDetailView {
    private var bottomView: some View {
        HStack {
            Image(systemName: !isLiked ? "heart": "heart.fill")
                .font(.system(size: 30))
                .foregroundStyle(!isLiked ? .gray800 : .heartRed)
                .padding(.leading, 15)
                .onTapGesture {
                    Task {
                        await tradeViewModel.updateLikeTrade(trade: tradeViewModel.trade)
                    }
                    isLiked.toggle()
                }
                .padding()
                .padding(.leading, -10)
            
            switch tradeViewModel.trade.category {
            case .nanua:
                Text("\(tradeViewModel.trade.myProduct)")
                    .font(ANBDFont.SubTitle1)
                
            case .baccua:
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("줄 것    ")
                            .foregroundStyle(.gray400)
                            .font(ANBDFont.SubTitle3)
                        
                        Text(isMine ? tradeViewModel.trade.myProduct : tradeViewModel.trade.wantProduct ?? "제시")
                            .font(ANBDFont.SubTitle2)
                    }
                    
                    HStack {
                        Text("받을 것")
                            .foregroundStyle(.gray400)
                            .font(ANBDFont.SubTitle3)
                        
                        Text(isMine ? tradeViewModel.trade.wantProduct ?? "제시" : tradeViewModel.trade.myProduct)
                            .font(ANBDFont.SubTitle2)
                    }
                }
                
            case .accua:
                EmptyView()
            case .dasi:
                EmptyView()
            }
            
            Spacer()
            
            if user.id != tradeViewModel.trade.writerID && tradeViewModel.trade.tradeState == .trading {
                RoundedRectangle(cornerRadius: 14)
                    .foregroundStyle(.accent)
                    .overlay {
                        Text("채팅하기")
                            .font(ANBDFont.pretendardMedium(16))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 100, height: 45)
                    .padding()
                    .onTapGesture {
                        Task {
                            try await chatViewModel.setSelectedUser(trade: trade)
                            coordinator.channel = nil
                            coordinator.trade = trade
                            tradeViewModel.getOneTrade(trade: trade)
                            
                            switch coordinator.selectedTab {
                            case .home, .article, .trade, .mypage:
                                coordinator.appendPath(Page.chatDetailView)
                            case .chat:
                                coordinator.pop()
                            }
                        }
                    }
            }
            
        }
        .onAppear {
            isMine = user.id == tradeViewModel.trade.writerID
        }
    }
}
