//
//  MypageView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

struct UserPageView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    
    // 이 유저 페이지는 마이페이지 눌렀을 때도 보이고 다른 유저 프로필 눌렀을 떄도 보여야 해서
    // 17번 줄의 변수로 유저 정보를 받아서 들어와용
    // 쥬리 이거????? 넵 그래서 이것도 프린트로 확인해보면
    // ㅒ
    var writerUser: User
    
    @State private var userProfileImageData = Data()
    
    @State private var category: ANBDCategory = .accua
    
    @State private var isSignedInUser: Bool = false
    
    @State private var isShowingPolicyView = false
    @State private var isShowingReportView = false
    
    var body: some View {
        VStack(spacing: 20) {
            // UserInfo
            HStack {
                Image(uiImage: UIImage(data: userProfileImageData) ?? UIImage(named: "DefaultUserProfileImage")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(.circle)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(writerUser.nickname)")
                        .foregroundStyle(Color.gray900)
                        .font(ANBDFont.pretendardBold(24))
                        .padding(.bottom, 10)
                    
                    Text("선호 지역 : \(writerUser.favoriteLocation.description)")
                        .foregroundStyle(Color.gray400)
                        .font(ANBDFont.Caption3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if isSignedInUser {
                        HStack {
                            Text(verbatim: "\(writerUser.email)")
                                .foregroundStyle(Color.gray400)
                            
                            Spacer()
                            
                            Button(action: {
                                myPageViewModel.myPageNaviPath.append(MyPageViewModel.MyPageNaviPaths.accountManagement)
                            }, label: {
                                Text("계정관리")
                            })
                        }
                        .font(ANBDFont.Caption3)
                    }
                }
            }
            .padding()
            
            HStack(spacing: 12) {
                activityInfoComponent(title: "아껴 쓴 개수", category: .accua)
                
                Divider()
                    .frame(height: 60)
                
                activityInfoComponent(title: "나눠 쓴 개수", category: .nanua)
                
                Divider()
                    .frame(height: 60)
                
                activityInfoComponent(title: "바꿔 쓴 개수", category: .baccua)
                
                Divider()
                    .frame(height: 60)
                
                activityInfoComponent(title: "다시 쓴 개수", category: .dasi)
            }
            
            if isSignedInUser {
                // Another Functions
                VStack(alignment: .leading) {
                    Divider()
                    
                    Button(action: {
                        myPageViewModel.myPageNaviPath.append(MyPageViewModel.MyPageNaviPaths.userHeartedTradeList)
                    }, label: {
                        listButtonView(title: "내가 찜한 나눔・거래 보기")
                    })
                    
                    Divider()
                    
                    Button(action: {
                        myPageViewModel.myPageNaviPath.append(MyPageViewModel.MyPageNaviPaths.userLikedArticleList)
                    }, label: {
                        listButtonView(title: "내가 좋아요한 게시글 보기")
                    })
                    
                    Divider()
                    
                    Button(action: {
                        isShowingPolicyView.toggle()
                    }, label: {
                        listButtonView(title: "약관 및 정책")
                    })
                    
                    Divider()
                }
                .fullScreenCover(isPresented: $isShowingPolicyView) {
                    SafariWebView(url: URL(string: "https://maru-study-note.tistory.com/")!)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            
            if isSignedInUser {
                Spacer()
            } else {
                Rectangle()
                    .fill(Color.gray50)
                    .ignoresSafeArea()
            }
        }
        .toolbarRole(.editor)
        .toolbar {
            if !isSignedInUser {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            tradeViewModel.tradePath.append("tradeToReport")
                        } label: {
                            Label("신고하기", systemImage: "exclamationmark.bubble")
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
        
        .navigationTitle("\(navigationTitle)")
        .navigationBarTitleDisplayMode(.inline)
        
        .fullScreenCover(isPresented: $isShowingReportView) {
            ReportView(reportedObjectID: writerUser.id)
        }
        
        .onAppear {
            isSignedInUser = myPageViewModel.checkSignInedUser(userID: writerUser.id)
            
            Task {
                // 유저 정보가 들어오면 그걸 바탕으로 그 유저의 게시글들을 다 불러오죠
                //이미 찍어보긴 했는데 봅시당!
                await myPageViewModel.loadArticlesWrittenByUser(userID: writerUser.id)
                await myPageViewModel.loadTradesWrittenByUser(userID: writerUser.id)
                
                
                
                // 쥬리 여기서!
                myPageViewModel.filterANBDListWrittenByUser()
                
                print("\(myPageViewModel.articlesWrittenByUser)")
                print("\(myPageViewModel.tradesWrittenByUser)")
                
                print("🦷\(writerUser.nickname)")
                
                // 요래?
                
                userProfileImageData = await myPageViewModel.loadUserProfileImage(containerID: "",
                                                                                  imagePath: myPageViewModel.user.profileImage)
            }
        }
    }
    
    private func activityInfoComponent(title: String, category: ANBDCategory) -> some View {
        NavigationLink(value: category) {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                // 그래서 그냥 유저페이지 뷰에서 저기 담긴 걸 이렇게 보여주는거구!!!
                Group {
                    switch category {
                    case .accua:
                        Text("\(myPageViewModel.accuaArticlesWrittenByUser.count)")
                    case .nanua:
                        Text("\(myPageViewModel.nanuaTradesWrittenByUser.count)")
                    case .baccua:
                        Text("\(myPageViewModel.baccuaTradesWrittenByUser.count)")
                    case .dasi:
                        Text("\(myPageViewModel.dasiArticlesWrittenByUser.count)")
                    }
                }
                .font(ANBDFont.pretendardSemiBold(22))
            }
        }
    }
    
    private func listButtonView(title: String) -> some View {
        Text("\(title)")
            .foregroundStyle(Color.gray900)
            .font(ANBDFont.SubTitle2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}

extension UserPageView {
    private var navigationTitle: String {
        switch isSignedInUser {
        case true: return "마이페이지"
        case false: return "사용자 정보"
        }
    }
    
    private var userProfileImage: UIImage {
        switch isSignedInUser {
        case true:
            return UIImage(data: userProfileImageData) ?? UIImage(named: "DefaultUserProfileImage")!
        case false:
            return UIImage(named: "DefaultUserProfileImage")!
        }
    }
}

#Preview {
    NavigationStack {
        UserPageView(writerUser: MyPageViewModel.mockUser)
            .environmentObject(MyPageViewModel())
    }
}
