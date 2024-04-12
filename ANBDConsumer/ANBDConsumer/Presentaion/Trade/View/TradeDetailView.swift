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
    @State private var isGoingToChatView: Bool = false
    @State private var isGoingToProfileView: Bool = false
    @State private var isShowingConfirm: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingStateChangeCustomAlert: Bool = false
    @State private var isShowingDeleteCustomAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    //임시..
    @State private var isLiked: Bool = false
    @State private var isWriter: Bool = true
    @State private var isTraiding: Bool = true
    @State private var detailImage: String = "DummpyPuppy1"
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        //이미지
                        TabView() {
                            //ForEach(trade.imagePaths, id: \.self) { item in
                            //                        AsyncImage(url: URL(string: item), content: { img in
                            //                            img.resizable()
                            //                                .scaledToFill()
                            //                                .containerRelativeFrame(.horizontal)
                            //                        }, placeholder: {
                            //                            ProgressView()
                            //                        })
                            Image(.dummyImage1)
                                .resizable()
                                .scaledToFill()
                                .containerRelativeFrame(.horizontal)
                                .onTapGesture {
                                    detailImage = "DummyImage1"
                                    isShowingImageDetailView.toggle()
                                }
                            Image(.dummyPuppy1)
                                .resizable()
                                .scaledToFill()
                                .containerRelativeFrame(.horizontal)
                                .onTapGesture {
                                    detailImage = "DummyPuppy1"
                                    isShowingImageDetailView.toggle()
                                }
                            Image(.dummyPuppy2)
                                .resizable()
                                .scaledToFill()
                                .containerRelativeFrame(.horizontal)
                                .onTapGesture {
                                    detailImage = "DummyPuppy2"
                                    isShowingImageDetailView.toggle()
                                }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
                        
                        //작성자 이미지, 닉네임, 작성시간
                        HStack {
                            Button(action: {
                                //프로필탭으로 이동
                                isGoingToProfileView.toggle()
                            }, label: {
                                Image(.dummyImage1) // UserViewModel과 연결해야함
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFill()
                                    .clipShape(Circle())
                            })
                            VStack(alignment: .leading) {
                                Text("\(trade.writerNickname)")
                                    .font(ANBDFont.SubTitle1)
                                    .foregroundStyle(.gray900)
                                
                                Text("\(trade.createdAt.relativeTimeNamed)")
                                    .font(ANBDFont.body2)
                                    .foregroundStyle(.gray600)
                            }
                            
                            Spacer()
                            
                            TradeStateChangeView(tradeState: $trade.tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert, fontSize: 17)
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
                    //task로 변경해주기~
                    if trade.tradeState == .trading {
                        trade.tradeState = .finish
                    } else {
                        trade.tradeState = .trading
                    }
                }
            }
            if isShowingDeleteCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingDeleteCustomAlert, viewType: .tradeDelete) {
                    print("삭제~")
                    self.dismiss()
                }
            }
        }//ZStack
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
            tradeViewModel.selectedLocation = .seoul
            tradeViewModel.selectedItemCategory = .digital
        }) {
            TradeCreateView(isShowingCreate: $isShowingCreat, isNewProduct: false, trade: trade)
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(imageString: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .navigationDestination(isPresented: $isGoingToReportView) {
            ReportView(reportViewType: .trade)
        }
        .navigationDestination(isPresented: $isGoingToProfileView) {
//            UserPageView(isSignedInUser: false)
        }
        .navigationTitle("나눔 · 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .confirmationDialog("", isPresented: $isShowingConfirm) {
            if isWriter {
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
                    isGoingToReportView.toggle()
                }
            }
        }
    }
}

extension TradeDetailView {
    private var bottomView: some View {
        HStack {
            Image(systemName: isLiked ? "heart": "heart.fill")
                .contentTransition(.symbolEffect(.replace))
                .font(.system(size: 30))
                .foregroundStyle(isLiked ? .gray200 : .heartRed)
                .padding(.leading, 15)
                .onTapGesture {
                    isLiked.toggle()
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
            
            if !isWriter {
                BlueSquareButton(height: 45, title: "채팅하기") {
                    isGoingToChatView.toggle()
                }
                .frame(width: 100)
                .padding()
                .navigationDestination(isPresented: $isGoingToChatView) {
                    ChatDetailView()
                }
            }
        }
    }
}
