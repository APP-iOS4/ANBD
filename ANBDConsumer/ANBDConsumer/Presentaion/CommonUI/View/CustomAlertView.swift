//
//  CustomAlertView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI

struct CustomAlertView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @Binding var isShowingCustomAlert: Bool
    var viewType: AlertViewType = .editingCancel
    var completionHandler: () -> Void
    
    var body: some View {
        ZStack {
            Color.gray900
                .opacity(0.3)
                .ignoresSafeArea()
            
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
                
                if viewType == .duplicatedEmail || viewType == .duplicatedNickname || viewType == .signInFail || viewType == .imageSelelct || viewType == .validEmail || viewType == .deletedCachingData {
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
                                    .fill(.gray300)
                                    .frame(height: 45)
                                
                                Text("취소하기")
                                    .foregroundStyle(.white)
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
            .foregroundStyle(.gray900)
            .padding(.vertical, 35)
            .background(
                RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
            )
            .padding(.horizontal, 45)
        }
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
        case validEmail
        case signUpCancel
        case emailRerequest
        case userKicked
        // trade
        case changeState
        case tradeDelete
        case articleEdit
        case articleDelete
        case commentDelete
        case writingCancel
        case report
        case commentEdit
        case imageSelelct
        case articleCreate
        // setting
        case editingCancel
        case deletedCachingData
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
        case .articleEdit, .commentEdit:
            return "수정 취소"
        case .commentDelete:
            return "댓글 삭제"
        case .writingCancel, .articleCreate:
            return "작성 취소"
        case .report:
            return "신고"
        case .imageSelelct:
            return "이미지 개수 제한"
        case .editingCancel:
            return "정보 수정 그만두기"
        case .validEmail:
            return "이메일 인증하기"
        case .signUpCancel:
            return "로그인으로 돌아가기"
        case .emailRerequest:
            return "뒤로가기"
        case .articleDelete:
            return "게시글 삭제"
        case .userKicked:
            return "접근 권한이 없습니다"
        case .deletedCachingData:
            return "캐시 데이터 삭제 완료"
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
        case .commentEdit:
            return "댓글 수정을 취소하시겠습니까?\n취소한 수정사항은 복구되지 않습니다."
        case .imageSelelct:
            return "이미지는 최대 5장만 가능합니다."
        case .articleCreate:
            return "게시글 작성을 취소하시겠습니까?\n취소한 작성사항은 복구되지 않습니다."
        case .editingCancel:
            return "변경된 내용은 저장되지 않습니다."
        case .validEmail:
            return "\(authenticationViewModel.signUpEmailString) 에서\n이메일 인증 링크를 확인해주세요."
        case .signUpCancel:
            return "로그인 화면으로 돌아가시겠습니까?\n진행하신 회원가입은 취소됩니다."
        case .emailRerequest:
            return "이메일 인증을 다시 진행해야합니다.\n돌아가시겠습니까?"
        case .userKicked:
            return "문의 사항은 이메일로 연락 바랍니다."
        case .deletedCachingData:
            return "캐시 데이터가 삭제되었습니다."
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
        case .duplicatedEmail, .duplicatedNickname, .signInFail, .imageSelelct, .userKicked, .deletedCachingData:
            return "확인"
        case .changeState:
            return "변경하기"
        case .tradeDelete, .articleDelete, .commentDelete:
            return "삭제하기"
        case .articleCreate:
            return "취소하기"
        case .report:
            return "신고하기"
        case .editingCancel:
            return "그만두기"
        case .writingCancel, .signUpCancel, .emailRerequest, .articleEdit, .commentEdit:
            return "돌아가기"
        case .validEmail:
            return "확인"
        }
    }
    
    private var confirmButtonColor: Color {
        switch viewType {
        case .leaveChatRoom, .duplicatedEmail, .duplicatedNickname, .signInFail, .changeState, .imageSelelct, .signOut, .editingCancel, .writingCancel, .validEmail, .signUpCancel, .emailRerequest, .userKicked, .deletedCachingData:
            return .accent
        case .withdrawal, .tradeDelete, .articleEdit, .articleDelete, .commentDelete, .report, .commentEdit, .articleCreate:
            return .heartRed
        }
    }
    
    private var textWeight: Font.Weight {
        switch viewType {
        case .leaveChatRoom, .signOut, .duplicatedEmail, .duplicatedNickname, .signInFail, .changeState, .tradeDelete, .writingCancel, .articleEdit, .articleDelete, .commentDelete, .report, .commentEdit, .imageSelelct, .editingCancel, .articleCreate, .validEmail, .signUpCancel, .emailRerequest, .userKicked, .deletedCachingData:
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
    .environmentObject(AuthenticationViewModel())
}
