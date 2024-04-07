//
//  ArticleEditView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/7/24.
//

import SwiftUI
import PhotosUI

struct ArticleEditView: View {

    @Binding var isShowingEditView: Bool

    @State private var flag: Category = .accua
    @State private var title : String = ""
    @State private var content : String = ""
    
    @State private var isShowingImageAlert: Bool = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    @State private var articleImage: UIImage?
    
    var placeHolder : String = "ANBD 이용자들을 위해 여러분들의 Tip,Custom을 공유해주세요!"

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .foregroundStyle(.accent)
                        .frame(height: 50)
                        .opacity(0.8)
                    
                    HStack {
                        Text("안내")
                            .font(ANBDFont.SubTitle2)
                        
                        Text("명예훼손, 광고/홍보 목적의 글은 올리실 수 없어요.")
                    }
                    .font(ANBDFont.body1)
                }
                .foregroundStyle(.gray50)
                .padding(10)
                
                VStack {
                    TextField("제목을 입력하세요", text: $title)
                        .font(ANBDFont.Heading3)
                        .padding(.leading, 20)
                    Divider()
                        .padding(.horizontal, 20)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text(placeHolder)
                                .foregroundStyle(.gray400)
                                .font(ANBDFont.body1)
                                .padding(.leading , 20)
                                .padding(.top , 8)
                        }
                        
                        TextEditor(text: $content)
                            .scrollContentBackground(.hidden)
                            .font(ANBDFont.body1)
                            .padding(.leading, 15)
                    }
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImageData, id: \.self) {
                                photoData in
                                ZStack(alignment:.topTrailing) {
                                    if let image = UIImage(data: photoData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width : 70 , height: 70)
                                            .cornerRadius(10)
                                            .clipped()
                                            .padding(10)
                                    }
                                    Button {
                                        if let idx = selectedImageData.firstIndex(of: photoData) {
                                            selectedImageData.remove(at: idx)
                                        }
                                    } label: {
                                        Circle()
                                            .overlay (
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(ANBDFont.pretendardSemiBold(20))
                                                    .foregroundStyle(.gray900)
                                            )
                                            .foregroundStyle(.gray50)
                                            .frame(width: 20, height:20)
                                    }
                                }
                            }
                        }
                    }
                }
                Divider()
                HStack {
                    if selectedImageData.count == 5 {
                        Button(action: {
                            isShowingImageAlert.toggle()
                        }, label: {
                            Image(systemName: "photo")
                            Text("사진")
                        })
                        .foregroundStyle(.accent)
                    } else {
                        PhotosPicker(
                            selection: $selectedItems, maxSelectionCount: 5-selectedImageData.count,
                            matching: .images
                        ) {
                            Image(systemName: "photo")
                            Text("사진")
                        }
                        .foregroundStyle(.accent)
                    }
                    
                    Spacer()
                }
                .frame(height: 40)
                .padding(.leading, 10)
            }
            .onChange(of: selectedItems) {
                for newItem in selectedItems {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedImageData.append(data)
                        }
                        if selectedImageData.count > 5 {
                            selectedImageData.removeLast()
                        }
                    }
                }
                selectedItems = []
            }
            .alert("이미지는 최대 5장만 가능합니다", isPresented: $isShowingImageAlert) {
                Button("확인", role: .cancel) { }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingEditView.toggle()
                    } label: {
                        Text("수정")
                            .disabled(title.isEmpty || content.isEmpty)
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        isShowingEditView.toggle()
                    } label: {
                        Text("취소")
                    }
                }
            }
            .navigationTitle("수정하기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ArticleEditView(isShowingEditView: .constant(true))
}
