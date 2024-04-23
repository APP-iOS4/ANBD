//
//  UserInfoEditorView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import ANBDModel
import PhotosUI

struct UserInfoEditingView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focus: FocusableField?
    
    @State private var isShowingProfileImageEditingDialog = false
    @State private var isShowingPhotosPicker = false
    @State private var isShowingMenuList = false
    @State private var isShwoingDuplicatedNicknameAlert = false
    
    @State private var photosPickerItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 40) {
                    if #available(iOS 17.0, *) {
                        userProfilImageButton
                            .onChange(of: photosPickerItem) {
                                Task {
                                    if let photosPickerItem, let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                        if let image = await UIImage(data: data)?.byPreparingThumbnail(ofSize: .init(width: 512, height: 512)) {
                                            myPageViewModel.userProfileImage = image
                                        }
                                    }
                                }
                            }
                    } else {
                        userProfilImageButton
                            .onChange(of: photosPickerItem, perform: { _ in
                                Task {
                                    if let photosPickerItem, let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                        if let image = await UIImage(data: data)?.byPreparingThumbnail(ofSize: .init(width: 512, height: 512)) {
                                            myPageViewModel.userProfileImage = image
                                        }
                                    }
                                }
                            })
                    }
                    
                    VStack(alignment: .leading) {
                        Text("닉네임")
                            .font(ANBDFont.SubTitle2)
                            .foregroundStyle(Color.gray400)
                            .padding(.bottom, 5)
                        
                        if #available(iOS 17.0, *) {
                            nicknameTextField
                                .onChange(of: myPageViewModel.tempUserNickname) {
                                    myPageViewModel.tempUserNickname = myPageViewModel.checkNicknameLength(myPageViewModel.tempUserNickname)
                                }
                        } else {
                            nicknameTextField
                                .onChange(of: myPageViewModel.tempUserNickname) { _ in
                                    myPageViewModel.tempUserNickname = myPageViewModel.checkNicknameLength(myPageViewModel.tempUserNickname)
                                }
                        }
                        
                        Divider()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(myPageViewModel.tempUserNickname.count) / 20")
                                .padding(.horizontal, 5)
                                .font(ANBDFont.body2)
                                .foregroundStyle(.gray400)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading) {
                        Text("선호하는 거래 지역")
                            .font(ANBDFont.SubTitle2)
                            .foregroundStyle(Color.gray400)
                            .padding(.bottom, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LocationPickerMenu(isShowingMenuList: $isShowingMenuList, selectedItem: $myPageViewModel.tempUserFavoriteLocation)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                
                if isShwoingDuplicatedNicknameAlert {
                    CustomAlertView(isShowingCustomAlert: $isShwoingDuplicatedNicknameAlert, viewType: .duplicatedNickname) {
                        focus = .nickname
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button(action: {
                        downKeyboard()
                    }, label: {
                        Label("Keyboard down", systemImage: "keyboard.chevron.compact.down")
                    })
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            if await myPageViewModel.checkDuplicatedNickname() {
                                downKeyboard()
                                isShwoingDuplicatedNicknameAlert.toggle()
                            } else {
                                dismiss()
                                
                                await myPageViewModel.updateUserInfo(updatedNickname: myPageViewModel.tempUserNickname,
                                                                     updatedLocation: myPageViewModel.tempUserFavoriteLocation)
                            }
                        }
                    }, label: {
                        Text("완료")
                    })
                    .disabled(myPageViewModel.validateUpdatingComplete())
                }
            }
            
            .navigationTitle("수정하기")
            .navigationBarTitleDisplayMode(.inline)
            
            .onAppear {
                myPageViewModel.tempUserNickname = UserStore.shared.user.nickname
            }
        }
    }
    
    private var userProfilImageButton: some View {
        Button(action: {
            isShowingProfileImageEditingDialog.toggle()
        }, label: {
            Image(uiImage: myPageViewModel.userProfileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(.circle)
                .overlay {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.gray800, Color.gray300)
                        .frame(width: 35)
                        .offset(x: 40.0, y: 40.0)
                }
        })
        .padding(.top, 25)
        
        .confirmationDialog("프로필 이미지 수정하기", isPresented: $isShowingProfileImageEditingDialog) {
            Button(action: {
                myPageViewModel.userProfileImage = UIImage(named: "DefaultUserProfileImage.001.png")!
            }, label: {
                Text("기본 이미지 사용하기")
            })
            
            Button(action: {
                isShowingPhotosPicker.toggle()
            }, label: {
                Text("앨범에서 선택하기")
            })
        }
        
        .photosPicker(isPresented: $isShowingPhotosPicker, selection: $photosPickerItem)
    }
    
    private var nicknameTextField: some View {
        textFieldUIKit(placeholder: "닉네임을 입력해주세요.",
                       text: $myPageViewModel.tempUserNickname)
        .focused($focus, equals: .nickname)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .font(ANBDFont.SubTitle1)
        .foregroundStyle(Color.gray900)
    }
}

extension UserInfoEditingView {
    enum FocusableField {
        case nickname
    }
    
    private func textFieldUIKit(placeholder: String, text: Binding<String>) -> some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        
        return TextField(placeholder, text: text)
    }
    
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    UserInfoEditingView()
        .environmentObject(MyPageViewModel())
        .environmentObject(TradeViewModel())
}
