//
//  TradeDetailView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct TradeDetailView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var coordinator: Coordinator
    // @EnvironmentObject private var myPageViewMode: MyPageViewModel
    @State var trade: Trade
    
    @State private var isShowingCreat: Bool = false
    @State private var isGoingToProfileView: Bool = false
    @State private var isShowingConfirm: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingStateChangeCustomAlert: Bool = false
    @State private var isShowingDeleteCustomAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var detailImage: Image = Image("DummyPuppy1")
    @State private var imageData: [Data] = []
    
    @State private var writerUser: User?
    @State private var user = UserStore.shared.user
    
    @State private var isLiked: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        //이미지
                        TabView() {
                            ForEach(imageData, id: \.self) { photoData in
                                if let image = UIImage(data: photoData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .onTapGesture {
                                            detailImage = Image(uiImage: image)
                                            isShowingImageDetailView.toggle()
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
//                            NavigationLink(value: writerUser) {
//                                Image(.dummyImage1)
//                                    .resizable()
//                                    .frame(width: 40, height: 40)
//                                    .scaledToFill()
//                                    .clipShape(Circle())
//                            }
                            
                            Image(.dummyImage1)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaledToFill()
                                .clipShape(Circle())
                                .onTapGesture {
                                    coordinator.user = writerUser
                                    coordinator.appendPath(.userPageView)
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
                                TradeStateChangeView(tradeState: $tradeViewModel.trade.tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert, fontSize: 17)
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
                        await tradeViewModel.reloadAllTrades()
                        self.dismiss()
                    }
                }
            }
        }//ZStack
        .onAppear {
            tradeViewModel.getOneTrade(trade: trade)
            isLiked = user.likeTrades.contains(tradeViewModel.trade.id)
            Task {
                writerUser = await myPageViewModel.getUserInfo(userID: tradeViewModel.trade.writerID)
                imageData = try await tradeViewModel.loadDetailImages(path: .trade, containerID: tradeViewModel.trade.id, imagePath: tradeViewModel.trade.imagePaths)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingConfirm.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCreat) {
            TradeCreateView(isShowingCreate: $isShowingCreat, isNewProduct: false, trade: tradeViewModel.trade)
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .navigationTitle("나눔 · 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .confirmationDialog("", isPresented: $isShowingConfirm) {
            if let user = UserDefaultsClient.shared.userInfo {
                if user.id == tradeViewModel.trade.writerID {
                    Button("수정하기") {
                        isShowingCreat.toggle()
                        tradeViewModel.selectedLocation = tradeViewModel.trade.location
                        tradeViewModel.selectedItemCategory = tradeViewModel.trade.itemCategory
                    }
                    
                    Button("삭제하기", role: .destructive) {
                        isShowingDeleteCustomAlert.toggle()
                    }
                } else {
                    Button("신고하기", role: .destructive) {
                        coordinator.reportType = .trade
                        coordinator.reportedObjectID = trade.id
                        coordinator.appendPath(.reportView)
                    }
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
            
            VStack(alignment: .leading) {
                
                switch tradeViewModel.trade.category {
                case .nanua:
                    Text("나눠쓰기")
                        .fontWeight(.bold)
                    Text("\(tradeViewModel.trade.myProduct)")
                case .baccua:
                    Text("바꿔쓰기")
                        .fontWeight(.bold)
                    HStack {
                        Text("\(tradeViewModel.trade.myProduct)")
                        Image(systemName: "arrow.left.and.right")
                        if let want = tradeViewModel.trade.wantProduct {
                            Text("\(want)")
                        } else {
                            Text("제시")
                        }
                    }
                    .font(ANBDFont.SubTitle2)
                    .foregroundStyle(.gray900)
                case .accua:
                    EmptyView()
                case .dasi:
                    EmptyView()
                }
            }
            .padding(.leading, -10)
            
            Spacer()
            
            
            if user.id != tradeViewModel.trade.writerID {
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
                        coordinator.trade = trade
                        switch coordinator.selectedTab {
                        case .home:
                            coordinator.homePath.append(Page.chatDetailView)
                        case .article:
                            return
                        case .trade:
                            coordinator.tradePath.append(Page.chatDetailView)
                        case .chat:
                            coordinator.pop()
                        case .mypage:
                            return
                        }
                    }
            }
            
        }
    }
}
