//
//  CustomAlertView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI

struct CustomAlertView: View {
    
    @Binding var isShowingCustomAlert: Bool
    var viewType: AlertViewType = .leaveChatRoom
    var completionHandler: () -> Void
    
    var body: some View {
        ZStack {
            Color.gray900
                .opacity(0.3)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .frame(height: 200)
                
                VStack {
                    Text(title)
                        .font(ANBDFont.SubTitle1)
                        .padding(.vertical, 10)
                    
                    Text(description)
                        .multilineTextAlignment(.center)
                        .font(ANBDFont.body1)
                        .padding(.bottom, 15)
                    
                    
                    HStack {
                        Button(action: {
                            isShowingCustomAlert.toggle()
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray100)
                                    .frame(height: 45)
                                
                                Text("취소")
                            }
                        })
                        .padding(.leading, 15)
                        
                        Button(action: {
                            completionHandler()
                            isShowingCustomAlert.toggle()
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(confirmButtonColor)
                                    .frame(height: 45)
                                
                                Text(confirmMessage)
                                    .foregroundStyle(.white)
                                    .fontWeight(textWeight)
                            }
                        })
                        .padding(.trailing, 15)
                    }
                    .font(ANBDFont.body1)
                }
            }
            .padding(.horizontal, 50)
            .foregroundStyle(.gray900)
        }
        .ignoresSafeArea()
    }
}

extension CustomAlertView {
    enum AlertViewType {
        case leaveChatRoom
        case signOut
        case withdrawal
    }
    
    private var title: String {
        switch viewType {
        case .leaveChatRoom:
            return "채팅방 나가기"
        case .signOut:
            return "로그아웃"
        case .withdrawal:
            return "회원 탈퇴"
        }
    }
    
    private var description: String {
        switch viewType {
        case .leaveChatRoom:
            return "정말 채팅방을 나가시겠습니까?\n채팅 내용은 복구되지 않습니다."
        case .signOut:
            return "정말 로그아웃 하시겠습니까?"
        case .withdrawal:
            return "정말 ANBD 회원에서 탈퇴하시겠습니까?\n회원 탈퇴 시 회원 정보가\n복구되지 않습니다."
        }
    }
    
    private var confirmMessage: String {
        switch viewType {
        case .leaveChatRoom:
            return "채팅방 나가기"
        case .signOut:
            return "로그아웃하기"
        case .withdrawal:
            return "탈퇴하기"
        }
    }
    
    private var confirmButtonColor: Color {
        switch viewType {
        case .leaveChatRoom:
            return .accent
        case .signOut:
            return .heartRed
        case .withdrawal:
            return .heartRed
        }
    }
    
    private var textWeight: Font.Weight {
        switch viewType {
        case .leaveChatRoom:
            return .medium
        case .signOut:
            return .medium
        case .withdrawal:
            return .heavy
        }
    }
}

#Preview {
    CustomAlertView(isShowingCustomAlert: .constant(true)) {
        print("Tap Confirm Button")
    }
}
