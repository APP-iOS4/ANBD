//
//  UserInfoEditorView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import PhotosUI

struct UserInfoEditorView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingProfileImageEditingDialog = false
    @State private var isShowingPhotosPicker = false
    
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var userProfileImage: UIImage?
    @State private var userNickname: String = ""
    @State private var selectedFavoriteLocation: TestLocation = .seoul
    
    var body: some View {
        VStack(spacing: 40) {
            CustomTitleBar()
            
            EditUserProfileImageView()
            
            EditUserNicknameView()
            
            EditUseFavoriteLocationView()
            
            Spacer()
        }
        .onAppear {
            myPageViewModel.editedUserNickname = myPageViewModel.user.nickname
        }
    }
    
    @ViewBuilder
    private func CustomTitleBar() -> some View {
        HStack {
            Button(action: {
                // MARK: 수정사항이 있었으면 Alert
                dismiss()
            }, label: {
                Image(systemName: "xmark")
            })
            
            Spacer()
            
            Button(action: {
                // 닉네임이 비어있으면 안됨!
            }, label: {
                Text("완료")
            })
            .disabled(myPageViewModel.checkVaildEditingComplete())
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .overlay {
            Text("수정하기")
                .fontWeight(.semibold)
        }
    }
    
    @ViewBuilder
    private func EditUserProfileImageView() -> some View {
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
        
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem, let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                    if let image = await UIImage(data: data)?.byPreparingThumbnail(ofSize: .init(width: 512, height: 512)) {
                        myPageViewModel.userProfileImage = image
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func EditUserNicknameView() -> some View {
        VStack(alignment: .leading) {
            Text("닉네임")
                .font(ANBDFont.SubTitle2)
                .foregroundStyle(Color.gray400)
                .padding(.bottom, 5)
            
            TextFieldUIKit(placeholder: "닉네임을 입력해주세요.", text: $myPageViewModel.editedUserNickname)
                .font(ANBDFont.SubTitle1)
                .foregroundStyle(Color.gray900)
            
            Divider()
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func EditUseFavoriteLocationView() -> some View {
        VStack(alignment: .leading) {
            Text("선호하는 거래 지역")
                .font(ANBDFont.SubTitle2)
                .foregroundStyle(Color.gray400)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LocationPickerMenu(selectedItem: $selectedFavoriteLocation)
                .frame(width: 170)
        }
        .padding(.horizontal, 20)
    }
    
    private func TextFieldUIKit(placeholder: String, text: Binding<String>) -> some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        
        return TextField(placeholder, text: text)
    }
}

#Preview {
    UserInfoEditorView()
        .environmentObject(MyPageViewModel())
}
