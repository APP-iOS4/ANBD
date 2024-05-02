//
//  ArticleCreateView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import PhotosUI
import ANBDModel

@MainActor
struct ArticleCreateView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var coordinator: Coordinator

    @Binding var isShowingCreateView: Bool
    
    @State var category: ANBDCategory = .accua
    @State private var title: String = ""
    @State private var content: String = ""
    @State var commentCount: Int = 0
    
    @State private var isShowingCustomEditAlert: Bool = false
    @State private var isShowingCustomCreateAlert: Bool = false
    @State private var isShowingImageAlert: Bool = false
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var tmpSelectedData: [Data] = []
    @State private var selectedImageData: [Data] = []
    @State private var deletedPhotosData: [Int] = []
    
    @State private var selectedMenuText: String = "아껴쓰기"
    
    private let placeHolder: String = "ANBD 이용자들을 위해 여러분들의 아껴쓰기/다시쓰기 Tip을 전수해주세요!"
    
    var isNewArticle: Bool
    var article: Article?
    
    var body: some View {
        ZStack {
            NavigationStack {
                if #available(iOS 17.0, *) {
                    articleCreateView
                        .onChange(of: selectedItems) {
                            Task {
                                selectedImageData = []
                                for newItem in selectedItems {
                                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                                        selectedImageData.append(data)
                                    }
                                    
                                    if selectedImageData.count > 5 {
                                        selectedImageData.removeLast()
                                    }
                                }
                            }
                        }
                        .onChange(of: title) {
                            if title.count > 50 {
                                title = String(title.prefix(50))
                            }
                        }
                        .onChange(of: content) {
                            if content.count > 5000 {
                                content = String(content.prefix(5000))
                            }
                        }
                } else {
                    articleCreateView
                        .onChange(of: selectedItems)  { _ in
                            Task {
                                selectedImageData = []
                                
                                for newItem in selectedItems {
                                    
                                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                                        selectedImageData.append(data)
                                    }
                                    
                                    if selectedImageData.count > 5 {
                                        selectedImageData.removeLast()
                                    }
                                }
                            }
                        }
                        .onChange(of: title) { _ in
                            if title.count > 50 {
                                title = String(title.prefix(50))
                            }
                        }
                        .onChange(of: content) { _ in
                            if content.count > 5000 {
                                content = String(content.prefix(5000))
                            }
                        }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            if isShowingCustomEditAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomEditAlert, viewType: .articleEdit) {
                    isShowingCreateView = false
                }
            } else if isShowingImageAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingImageAlert, viewType: .imageSelelct) { }
                
            } else if isShowingCustomCreateAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomCreateAlert, viewType: .articleCreate) {
                    isShowingCreateView = false
                }
            }
        }
    }
    
    private var articleCreateView: some View {
        VStack {
            InstructionsView()
            VStack {
                TextField("제목을 입력하세요.", text: $title, axis: .vertical)
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
                    .padding(.trailing, 12)
                
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
                        .padding(.leading, 15)
                        .padding(.trailing, 9)
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
                        ForEach(tmpSelectedData, id: \.self) { photoData in
                            ZStack(alignment:.topTrailing) {
                                
                                if let image = UIImage(data: photoData) {
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width : 70 , height: 70)
                                        .cornerRadius(10)
                                        .clipped()
                                        .padding(10)
                                }
                                
                                Circle()
                                    .overlay (
                                        Image(systemName: "xmark.circle.fill")
                                            .font(ANBDFont.pretendardSemiBold(20))
                                            .foregroundStyle(.gray900)
                                    )
                                    .foregroundStyle(.gray50)
                                    .frame(width: 20, height: 30)
                                    .onTapGesture {
                                        if let idx = tmpSelectedData.firstIndex(of: photoData) {
                                            deletedPhotosData.append(idx)
                                            tmpSelectedData.remove(at: idx)
                                        }
                                    }
                            }
                        }
                        ForEach(selectedImageData, id: \.self) { photoData in
                            ZStack(alignment:.topTrailing) {
                                
                                if let image = UIImage(data: photoData) {
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width : 70 , height: 70)
                                        .cornerRadius(10)
                                        .clipped()
                                        .padding(10)
                                }
                                
                                Circle()
                                    .overlay (
                                        Image(systemName: "xmark.circle.fill")
                                            .font(ANBDFont.pretendardSemiBold(20))
                                            .foregroundStyle(.gray900)
                                    )
                                    .foregroundStyle(.gray50)
                                    .frame(width: 20, height: 30)
                                    .onTapGesture {
                                        if let idx = selectedImageData.firstIndex(of: photoData) {
                                            selectedImageData.remove(at: idx)
                                            selectedItems.remove(at: idx)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            Divider()
            
            HStack {
                if tmpSelectedData.count + selectedImageData.count == 5 {
                    Button {
                        isShowingImageAlert.toggle()
                    } label: {
                        Image(systemName: "photo")
                        Text("사진")
                    }
                    .foregroundStyle(.accent)
                } else {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 5-tmpSelectedData.count, matching: .images) {
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
        .onAppear {
            if !isNewArticle {
                if let article = article {
                    
                    self.title = article.title
                    self.category = article.category
                    self.content = article.content
                    
                    Task {
                        tmpSelectedData = try await articleViewModel.loadDetailImages(path: .article, containerID: article.id, imagePath: article.imagePaths)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        if isNewArticle {
                            await articleViewModel.writeArticle(category: category, title: title, content: content, imageDatas: selectedImageData)
                            await articleViewModel.refreshSortedArticleList(category: category)
                        } else {
                            if var article = article {
                                
                                article.title = self.title
                                article.content = self.content
                                article.category = self.category
                                article.commentCount = self.commentCount
                                
                                await articleViewModel.updateArticle(category: category, title: title, content: content, commentCount: commentCount, addImages: selectedImageData, deletedImagesIndex: deletedPhotosData)
                                await articleViewModel.refreshSortedArticleList(category: category)
                                await articleViewModel.loadOneArticle(articleID: article.id)
                            }
                        }
                        await articleViewModel.refreshSortedArticleList(category: category)
                        isShowingCreateView = false
                    }
                    self.isShowingCreateView.toggle()
                } label: {
                    Text("완료")
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || title == article?.title && content == article?.content && category == article?.category && (deletedPhotosData.isEmpty && selectedImageData.isEmpty))

            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if !isNewArticle {
                        if let article = article {
                            let isTitleChanged = title != article.title
                            let isContentChanged = content != article.content
                            let isImageChanged = tmpSelectedData != selectedImageData
                            
                            if isTitleChanged || isContentChanged || isImageChanged {
                                isShowingCustomEditAlert.toggle()
                            } else {
                                isShowingCreateView.toggle()
                            }
                        }
                    } else {
                        if !title.isEmpty || !content.isEmpty {
                            isShowingCustomCreateAlert.toggle()
                        } else {
                            isShowingCreateView.toggle()
                        }
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
        .navigationTitle(category == .accua ? "아껴쓰기" : "다시쓰기")
        .navigationBarTitleDisplayMode(.inline)
    }
}
