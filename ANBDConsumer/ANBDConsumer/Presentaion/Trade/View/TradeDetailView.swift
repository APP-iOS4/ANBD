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
                            if let writerUser {
                                KFImage(URL(string: writerUser.profileImage))
                                    .placeholder({ _ in
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                    })
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFill()
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
                        await tradeViewModel.reloadFilteredTrades(category: trade.category)
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
        .fullScreenCover(isPresented: $isShowingCreat) {
            TradeCreateView(isShowingCreate: $isShowingCreat, isNewProduct: false, trade: tradeViewModel.trade)
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
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
                        .font(.system(size: 13))
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
                        Text("줄 것")
                            .foregroundStyle(.gray400)
                            .font(ANBDFont.SubTitle3)
                        Text("\(tradeViewModel.trade.myProduct)")
                            .font(ANBDFont.SubTitle2)
                        
                    }
                    HStack {
                        if let want = tradeViewModel.trade.wantProduct {
                            Text("받을 것")
                                .foregroundStyle(.gray400)
                                .font(ANBDFont.SubTitle3)
                            Text("\(want)") //8자 제한주기
                                .font(ANBDFont.SubTitle2)
                            
                        } else {
                            Text("제시")
                                .font(ANBDFont.SubTitle2)
                        }
                    }
                }
                .padding(.leading, -10)
            case .accua:
                EmptyView()
            case .dasi:
                EmptyView()
            }
            
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
}
