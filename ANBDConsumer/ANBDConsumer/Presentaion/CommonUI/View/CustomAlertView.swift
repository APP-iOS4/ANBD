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
                                    .fill(Color.accentColor)
                                    .frame(height: 45)
                                
                                Text(confirmMessage)
                                    .foregroundStyle(.white)
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
    }
    
    private var title: String {
        switch viewType {
        case .leaveChatRoom:
            return "채팅방 나가기"
        }
    }
    
    private var description: String {
        switch viewType {
        case .leaveChatRoom:
            return "정말 채팅방을 나가시겠습니까?\n채팅 내용은 복구되지 않습니다."
        }
    }
    
    private var confirmMessage: String {
        switch viewType {
        case .leaveChatRoom:
            return "채팅방 나가기"
        }
    }
}

#Preview {
    CustomAlertView(isShowingCustomAlert: .constant(true)) {
        print("Tap Confirm Button")
    }
}
