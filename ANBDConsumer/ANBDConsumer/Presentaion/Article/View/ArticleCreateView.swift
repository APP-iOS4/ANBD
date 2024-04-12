//
//  ArticleCreateView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import PhotosUI
import ANBDModel

struct ArticleCreateView: View {
    
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @Binding var isShowingCreateView: Bool
    
    @State var category: ANBDCategory = .accua
    @State private var title: String = ""
    @State private var content : String = ""
    @State var placeHolder : String = "ANBD 이용자들을 위해 여러분들의 아껴쓰기/다시쓰기 Tip을 전수해주세요!"
    
    @State private var isShowingImageAlert: Bool = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    
    @State private var selectedMenuText: String = "아껴쓰기"
    
    @State private var isShowingCustomAlert: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var isNewArticle: Bool
    var article: Article?
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    InstructionsView()
                    
                    VStack {
                        TextField("제목을 입력하세요", text: $title)
                        
                            .onAppear {
                                UITextField.appearance().clearButtonMode = .never
                                if !isNewArticle {
                                    if let article = article {
                                        self.title = article.title
                                    }
                                }
                            }
                            .font(ANBDFont.pretendardBold(24))
                            .padding(.leading, 20)
                        Divider()
                            .padding(.horizontal, 20)
                        
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text(placeHolder)
                                    .foregroundStyle(.gray400)
                                    .font(ANBDFont.body1)
                                    .padding(.horizontal, 20)
                                    .padding(.top , 8)
                            }
                            TextEditor(text: $content)
                                .scrollContentBackground(.hidden)
                                .font(ANBDFont.body1)
                                .padding(.horizontal, 20)
                                .onAppear {
                                    if !isNewArticle {
                                        if let article = article {
                                            self.content = article.content
                                        }
                                    }
                                }
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
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isShowingCreateView.toggle()
                        } label: {
                            Text("완료")
                        }
                        .disabled(title.isEmpty || content.isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            if !isNewArticle {
                                if let article = article {
                                    let hasTitleChanged = title != article.title
                                    let hasContentChanged = content != article.content
                                    if hasTitleChanged || hasContentChanged {
                                        isShowingCustomAlert.toggle()
                                    } else {
                                        isShowingCreateView.toggle()
                                    }
                                }
                            } else {
                                isShowingCreateView.toggle()
                            }
                        } label: {
                            Text("취소")
                        }
                    }
                }
                .toolbarTitleMenu {
                    Button {
                        category = .accua
                        selectedMenuText = "아껴쓰기"
                    } label: {
                        Text("아껴쓰기")
                    }
                    
                    Button {
                        category = .dasi
                        selectedMenuText = "다시쓰기"
                    } label: {
                        Text("다시쓰기")
                    }
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
                .navigationTitle(category == .accua ? "아껴쓰기" : "다시쓰기")
                .navigationBarTitleDisplayMode(.inline)
            }
            if isShowingCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlert, viewType: .articleEdit) {
                    dismiss()
                }
                .zIndex(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    ArticleCreateView(isShowingCreateView: .constant(true), category: .accua, isNewArticle: false)
}

