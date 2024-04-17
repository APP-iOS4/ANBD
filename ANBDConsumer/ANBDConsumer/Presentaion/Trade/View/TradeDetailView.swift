//
//  TradeDetailView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct TradeDetailView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @State var trade: Trade
    @State private var isGoingToReportView: Bool = false
    @State private var isShowingCreat: Bool = false
    @State private var isGoingToProfileView: Bool = false
    @State private var isShowingConfirm: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingStateChangeCustomAlert: Bool = false
    @State private var isShowingDeleteCustomAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var detailImage: Image = Image("DummyPuppy1")
    @State private var imageData: [Data] = []
    
    //임시..
    @State private var isLiked: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        //이미지
                        TabView() {
//                            ForEach(trade.imagePaths, id: \.self) { item in
//                                Image(item)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .onTapGesture {
//                                        detailImage = item
//                                        isShowingImageDetailView.toggle()
//                                    }
//                            }
                            if let uiImage = UIImage(data: imageData.first ?? Data()) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .onTapGesture {
                                        detailImage = Image(uiImage: uiImage)
                                        isShowingImageDetailView.toggle()
                                    }
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
                        
                        //작성자 이미지, 닉네임, 작성시간
                        HStack {
                            NavigationLink(value: "tradeToUser") {
                                Image(.dummyImage1)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFill()
                                    .clipShape(Circle())
                            }
        
                            VStack(alignment: .leading) {
                                Text("\(trade.writerNickname)")
                                    .font(ANBDFont.SubTitle1)
                                    .foregroundStyle(.gray900)
                                
                                Text("\(trade.createdAt.relativeTimeNamed)")
                                    .font(ANBDFont.body2)
                                    .foregroundStyle(.gray600)
                            }
                            
                            Spacer()
                            
                            if let user = UserDefaultsClient.shared.userInfo {
                                if user.id == trade.writerID {
                                    TradeStateChangeView(tradeState: $trade.tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert, fontSize: 17)
                                }
                            }
                        }//HStack
                        .padding(5)
                        .padding(.horizontal, 5)
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("\(trade.title)")
                                .font(ANBDFont.Heading3)
                                .foregroundStyle(.gray900)
                                .fontWeight(.bold)
                                .padding(.bottom, 1)
                            Text("\(trade.itemCategory.rawValue) · \(trade.location.description)")
                                .font(ANBDFont.body1)
                                .foregroundStyle(.gray500)
                                .padding(.bottom)
                            
                            Text("\(trade.content)")
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
                        await tradeViewModel.updateState(trade: trade)
                    }
                }
            }
            if isShowingDeleteCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingDeleteCustomAlert, viewType: .tradeDelete) {
                    Task {
                        print("삭제!")
                        await tradeViewModel.deleteTrade(trade: trade)
                        await tradeViewModel.reloadAllTrades()
                        self.dismiss()
                    }
                }
            }
        }//ZStack
        .onAppear {
            tradeViewModel.getOneTrade(trade: trade)
            Task {
                imageData = try await tradeViewModel.loadDetailImages(path: .trade, containerID: trade.id, imagePath: trade.imagePaths)
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
        .fullScreenCover(isPresented: $isShowingCreat, onDismiss: {
            //userviewmodel에서 user 선호 지역으로 바꾸기
            tradeViewModel.selectedLocation = .seoul
            tradeViewModel.selectedItemCategory = .digital
            Task {
                await tradeViewModel.loadOneTrade(trade: trade)
                trade = tradeViewModel.trade
            }
        }) {
            TradeCreateView(isShowingCreate: $isShowingCreat, isNewProduct: false, trade: trade)
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
//            ImageDetailView(imageString: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .navigationTitle("나눔 · 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .confirmationDialog("", isPresented: $isShowingConfirm) {
            if let user = UserDefaultsClient.shared.userInfo {
                if user.id == trade.writerID {
                    Button("수정하기") {
                        isShowingCreat.toggle()
                        tradeViewModel.selectedLocation = trade.location
                        tradeViewModel.selectedItemCategory = trade.itemCategory
                    }
                    
                    Button("삭제하기", role: .destructive) {
                        isShowingDeleteCustomAlert.toggle()
                    }
                } else {
                    Button("신고하기", role: .destructive) {
                        tradeViewModel.tradePath.append("tradeToReport")
                    }
                }
            }
        }
    }
}

extension TradeDetailView {
    private var bottomView: some View {
        HStack {
            Image(systemName: isLiked ? "heart": "heart.fill")
                .font(.system(size: 30))
                .foregroundStyle(isLiked ? .gray200 : .heartRed)
                .padding(.leading, 15)
                .onTapGesture {
                    withAnimation {
                        isLiked.toggle()
                    }
                }
                .padding()
                .padding(.leading, -10)
            
            VStack(alignment: .leading) {
                
                switch trade.category {
                case .nanua:
                    Text("나눠쓰기")
                        .fontWeight(.bold)
                    Text("\(trade.myProduct)")
                case .baccua:
                    Text("바꿔쓰기")
                        .fontWeight(.bold)
                    HStack {
                        Text("\(trade.myProduct)")
                        Image(systemName: "arrow.left.and.right")
                        if let want = trade.wantProduct {
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
            
            if let user = UserDefaultsClient.shared.userInfo { 
                if user.id != trade.writerID {
                    NavigationLink(value: "tradeToChat") {
                        RoundedRectangle(cornerRadius: 14)
                            .foregroundStyle(.accent)
                            .overlay {
                                Text("채팅하기")
                                    .font(ANBDFont.pretendardMedium(16))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 100, height: 45)
                            .padding()
                    }
                }
            }
        }
    }
}
