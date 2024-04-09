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
    @State private var isShowingDeleteAlert: Bool = false
    @State private var isShowingCreat: Bool = false
    @State private var isGoingToChatView: Bool = false
    @State private var isGoingToProfileView: Bool = false
    
    //임시..
    @State private var isLiked: Bool = false
    @State private var isWriter: Bool = false
    @State private var isTraiding: Bool = true
    
    var body: some View {
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
                        ForEach(0..<3) { _ in
                            Image(.dummyImage1)
                                .resizable()
                                .scaledToFill()
                                .containerRelativeFrame(.horizontal)
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
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                        })
                        
                        Text("\(trade.writerNickname)")
                            .font(ANBDFont.SubTitle1)
                            .foregroundStyle(.gray900)
                        
                        Spacer()
                        
                        Text("\(trade.createdAt.relativeTimeNamed)")
                            .font(ANBDFont.SubTitle1)
                            .foregroundStyle(.gray600)
                    }//HStack
                    .padding(10)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        if isWriter {
                            TradeStateChangeView(isTrading: $isTraiding)
                        }
                        Text("\(trade.title)")
                            .font(ANBDFont.Heading3)
                            .foregroundStyle(.gray900)
                            .fontWeight(.bold)
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
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if isWriter {
                        Button(action: {
                            isShowingCreat.toggle()
                            tradeViewModel.selectedLocation = trade.location
                            tradeViewModel.selectedItemCategory = trade.itemCategory
                        }, label: {
                            Label("수정하기", systemImage: "square.and.pencil")
                        })
                        Button(role: .destructive) {
                            isShowingDeleteAlert.toggle()
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive, action: {
                            isGoingToReportView.toggle()
                        }, label: {
                            Label("신고하기", systemImage: "exclamationmark.bubble")
                        })}
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCreat, onDismiss: {
            tradeViewModel.selectedLocation = .seoul
            tradeViewModel.selectedItemCategory = .digital
        }) {
            TradeCreateView(isShowingCreate: $isShowingCreat, isNewProduct: false, trade: trade)
        }
        .navigationDestination(isPresented: $isGoingToReportView) {
            ReportView(reportViewType: .trade)
        }
        .navigationDestination(isPresented: $isGoingToProfileView) {
            UserPageView(isSignedInUser: false)
        }
        .alert("상품을 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
            Button("삭제", role: .destructive) {
                
            }
            Button("취소", role: .cancel) {
                
            }
        }
    }
}

extension TradeDetailView {
    private var bottomView: some View {
        HStack {
            Image(systemName: isLiked ? "heart": "heart.fill")
                .contentTransition(.symbolEffect(.replace))
                .font(.system(size: 20))
                .foregroundStyle(isLiked ? .gray200 : .heartRed)
                .padding(.leading, 15)
                .onTapGesture {
                    isLiked.toggle()
                }
                .padding()
            
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
