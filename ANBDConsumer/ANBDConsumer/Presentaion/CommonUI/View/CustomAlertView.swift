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
                    .fill(Color(UIColor.systemBackground))
                    .frame(height: 200)
                
                VStack {
                    Text(title)
                        .font(ANBDFont.SubTitle1)
                        .foregroundStyle(.gray900)
                        .padding(.vertical, 10)
                    
                    Text(description)
                        .multilineTextAlignment(.center)
                        .font(ANBDFont.body1)
                        .foregroundStyle(.gray900)
                        .padding(.bottom, 15)
                    
                    if viewType == .duplicatedEmail || viewType == .duplicatedNickname || viewType == .signInFail {
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
                        .font(ANBDFont.body1)
                        .padding(.horizontal, 15)
                    } else {
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
        // auth
        case signOut
        case withdrawal
        case duplicatedEmail
        case duplicatedNickname
        case signInFail
        //trade
        case changeState
        case tradeDelete
        case articleEdit
        case articleDelete
        case commentDelete
        case writingCancel
        case report
    }
    
    private var title: String {
        switch viewType {
        case .leaveChatRoom:
            return "채팅방 나가기"
        case .signOut:
            return "로그아웃"
        case .withdrawal:
            return "회원 탈퇴"
        case .duplicatedEmail:
            return "중복된 이메일"
        case .duplicatedNickname:
            return "중복된 닉네임"
        case .signInFail:
            return "로그인 실패"
        case .changeState:
            return "거래 상태 변경"
        case .tradeDelete:
            return "삭제"
        case .articleEdit:
            return "수정 취소"
        case .articleDelete:
            return "게시글 삭제"
        case .commentDelete:
            return "댓글 삭제"
        case .writingCancel:
            return "작성 취소"
        case .report:
            return "신고"
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
        case .duplicatedEmail:
            return "이미 사용중인 이메일 입니다."
        case .duplicatedNickname:
            return "이미 사용중인 닉네임 입니다."
        case .signInFail:
            return "이메일 또는 비밀번호를 확인하세요."
        case .changeState:
            return "거래 상태를 변경하시겠습니까?"
        case .tradeDelete:
            return "상품을 삭제하시겠습니까?\n삭제 시 상품 정보는 복구되지 않습니다."
        case .articleEdit:
            return "게시글 수정을 취소하시겠습니까?\n취소한 수정사항은 복구되지 않습니다."
        case .articleDelete:
            return "해당 게시글을 삭제하시겠습니까?\n삭제한 게시글은 복구되지 않습니다."
        case .commentDelete:
            return "해당 댓글을 삭제하시겠습니까?\n삭제한 댓글은 복구되지 않습니다." 
        case .writingCancel:
            return "작성하던 내용을 삭제하고\n돌아가시겠습니까?"
        case .report:
            return "해당 내역을 신고하시겠습니까?"
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
        case .duplicatedEmail:
            return "확인"
        case .duplicatedNickname:
            return "확인"
        case .signInFail:
            return "확인"
        case .changeState:
            return "변경하기"
        case .tradeDelete, .writingCancel:
            return "삭제하기"
        case .articleEdit:
            return "취소하기"
        case .articleDelete:
            return "삭제하기"
        case .commentDelete:
            return "삭제하기"
        case .report:
            return "신고하기"
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
        case .duplicatedEmail:
            return .accent
        case .duplicatedNickname:
            return .accent
        case .signInFail:
            return .accent
        case .changeState:
            return .accent
        case .tradeDelete, .writingCancel:
            return .heartRed
        case .articleEdit:
            return .heartRed
        case .articleDelete:
            return .heartRed
        case .commentDelete:
            return .heartRed
        case .report:
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
        case .duplicatedEmail:
            return .medium
        case .duplicatedNickname:
            return .medium
        case .signInFail:
            return .medium
        case .changeState:
            return .medium
        case .tradeDelete, .writingCancel:
            return .medium
        case .articleEdit:
            return .medium
        case .articleDelete:
            return .medium
        case .commentDelete:
            return .medium
        case .report:
            return .medium
        }
    }
}

#Preview {
    CustomAlertView(isShowingCustomAlert: .constant(true)) {
        print("Tap Confirm Button")
    }
}
