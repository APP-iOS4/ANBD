import SwiftUI
import ANBDModel
import PhotosUI

struct TradeCreateView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @Binding var isShowingCreate: Bool
    @State private var placeHolder: String = ""
    @State private var isFinished: Bool = true
    @State private var isCancelable: Bool = true
    @State private var isShowingCategoryMenuList: Bool = false
    @State private var isShowingLocationMenuList: Bool = false
    @State private var isShowingBackAlert: Bool = false
    @State private var isShowingImageAlert: Bool = false
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State var category: ANBDCategory = .nanua
    
    @State var itemCategory: ItemCategory = .digital
    @State var location: Location = .seoul
    
    //B
    @State private var myProduct: String = ""
    @State private var wantProduct: String = ""
    
    //photo
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    //@State private var itemCategory
    private var mustTextFields: [String] {[
        title.description,
        content.description,
        myProduct.description
    ]}
    
    //update
    var isNewProduct: Bool = true
    var trade: Trade?
    
    var body: some View {
        if #available(iOS 17.0, *) {
            wholeView
                .onChange(of: mustTextFields, {
                    if self.selectedPhotosData.count != 0 && self.title != "" && self.myProduct != "" && self.content != "" {
                        self.isFinished = false
                    } else {
                        self.isFinished = true
                    }
                })
                .onChange(of: selectedPhotosData, {
                    if self.selectedPhotosData.count != 0 && self.title != "" && self.myProduct != "" && self.content != "" {
                        self.isFinished = false
                    } else {
                        self.isFinished = true
                    }
                    
                    isCancelable = false
                })
                
        } else {
            wholeView
                .onChange(of: mustTextFields) { _ in
                    if self.selectedPhotosData.count != 0 && self.title != "" && self.myProduct != "" && self.content != "" {
                        self.isFinished = false
                    } else {
                        self.isFinished = true
                    }
                }
                .onChange(of: selectedPhotosData) { _ in
                    if self.selectedPhotosData.count != 0 && self.title != "" && self.myProduct != "" && self.content != "" {
                        self.isFinished = false
                    } else {
                        self.isFinished = true
                    }
                    
                    isCancelable = false
                }
        }
    }
}

extension TradeCreateView {
    fileprivate var photosView: some View {
        HStack {
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 5-selectedPhotosData.count, matching: .images) {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(.gray)
                        .padding(3)
                    Text("0 / 5")
                        .foregroundStyle(.gray)
                        .font(.system(size: 15))
                }//VStack
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(.gray, lineWidth: 1)
                        .foregroundStyle(.clear)
                        .frame(width: 80, height: 80)
                )
                .padding(.bottom, 30)
            }
            .padding(.leading, 20)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedPhotosData, id: \.self) { photoData in
                        ZStack(alignment:.topTrailing){
                            if let image = UIImage(data: photoData) {
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width : 80 , height: 80)
                                    .cornerRadius(10)
                                    .clipped()
                                    .padding(10)
                                
                            }
                            
                            Button {
                                if let idx = selectedPhotosData.firstIndex(of: photoData) {
                                    selectedPhotosData.remove(at: idx)
                                }
                            } label: {
                                Circle()
                                    .overlay (
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.black)
                                    )
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height:20)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }//Horizontal ScrollView
            .padding(.horizontal, 20)
        }
    }
    fileprivate var wholeView: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        endTextEditing()
                        
                        // 수정: 바뀐 정보가 없다면 backAlert X
                        if let trade = trade {
                            if title != trade.title || content != trade.content || category != trade.category || myProduct != trade.myProduct || self.itemCategory != trade.itemCategory || self.location != trade.location {
                                isCancelable = false
                            }
                        }
                        
                        for item in mustTextFields {
                            if item != "" {
                                isCancelable = false
                            }
                        }
                        
                        if isCancelable {
                            isShowingCreate.toggle()
                        } else {
                            isShowingBackAlert.toggle()
                        }
                        
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    
                    Spacer()
                    
                    if isNewProduct {
                        Text("새 상품 등록")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                    } else {
                        Text("상품 수정")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }//HStack
                .foregroundStyle(.gray900)
                .padding()
                
                ScrollView {
                    if #available(iOS 17.0, *) {
                        photosView
                            .onChange(of: selectedItems) {
                                for newItem in selectedItems {
                                    Task {
                                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                                            selectedPhotosData.append(data)
                                        }
                                        if selectedPhotosData.count > 5 {
                                            selectedPhotosData.removeLast()
                                        }
                                    }
                                }
                            }
                    } else {
                        photosView
                            .onChange(of: selectedItems) { _ in
                                for newItem in selectedItems {
                                    Task {
                                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                                            selectedPhotosData.append(data)
                                        }
                                        if selectedPhotosData.count > 5 {
                                            selectedPhotosData.removeLast()
                                        }
                                    }
                                }
                            }
                    }
                    
                    //제목
                    VStack(alignment: .leading) {
                        Text("제목")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        
                        TextField("제목", text: $title)
                            .modifier(TextFieldModifier())
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    //거래 방식
                    VStack(alignment: .leading) {
                        Text("거래 방식")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        VStack(alignment: .leading) {
                            //나눠쓰기
                            if category == .nanua {
                                HStack {
                                    CapsuleButtonView(text: "나눠쓰기", buttonColor: .accent, fontColor: .white)
                                    
                                    CapsuleButtonView(text: "바꿔쓰기")
                                        .onTapGesture {
                                            self.category = .baccua
                                        }
                                }
                                .padding(.bottom, 10)
                                
                                HStack {
                                    TextField("나눌 물건", text: $myProduct)
                                        .modifier(TextFieldModifier())
                                }
                            } else {
                                //바꿔쓰기
                                HStack {
                                    CapsuleButtonView(text: "나눠쓰기")
                                        .onTapGesture {
                                            self.category = .nanua
                                        }
                                    
                                    CapsuleButtonView(text: "바꿔쓰기", buttonColor: .accent, fontColor: .white)
                                    
                                    Rectangle()
                                        .frame(width: 100, height: 0)
                                }
                                .padding(.bottom, 20)
                                
                                HStack {
                                    TextField("바꿀 물건", text: $myProduct)
                                        .modifier(TextFieldModifier())
                                    
                                    Image(systemName: "arrow.left.and.right")
                                    TextField("받고 싶은 물건", text: $wantProduct)
                                        .modifier(TextFieldModifier())
                                        .onAppear() {
                                            if !isNewProduct {
                                                if let trade = trade {
                                                    if let want = trade.wantProduct {
                                                        self.wantProduct = want
                                                    }
                                                }
                                            }
                                        }
                                }
                                
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                    
                    //카테고리
                    VStack(alignment: .leading) {
                        Text("카테고리")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        
                        ItemCategoryPickerMenu(isShowingMenuList: $isShowingCategoryMenuList, selectedItem: tradeViewModel.selectedItemCategory)
                            .onTapGesture {
                                self.isShowingLocationMenuList = false
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    //지역
                    VStack(alignment: .leading) {
                        Text("지역")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        
                        LocationPickerMenu(isShowingMenuList: $isShowingLocationMenuList, selectedItem: tradeViewModel.selectedLocation)
                            .onTapGesture {
                                self.isShowingCategoryMenuList = false
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    //상세설명
                    VStack(alignment: .leading) {
                        Text("상세설명")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text(category == .nanua ? "나누고자 하는 물건에 대한 설명을 작성해주세요.\n(거래 금지 물품은 게시가 제한될 수 있어요.)" : "내 물건에 대한 설명, 원하는 물건에 대한 설명 등\n바꿀 물건에 대한내용을 작성해주세요.\n\n받고 싶은 물건의 후보가 여러가지라면 여기에\n작성해주세요.\n(거래 금지 물품은 게시가 제한될 수 있어요.)")
                                    .foregroundStyle(Color(uiColor: .lightGray))
                                    .font(.system(size: 15))
                                    .padding(.leading , 21)
                                    .padding(.top , 25)
                            }
                            
                            TextEditor(text: $content)
                                .scrollContentBackground(.hidden)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(.gray)
                                )
                        }
                    }//VStack
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    //작성완료 버튼
                    BlueSquareButton(title: isNewProduct ? "작성 완료" : "수정 완료", isDisabled: isFinished) {
                        if !isNewProduct {
                            
                        } else {
                            
                        }
                        self.isShowingCreate.toggle()
                    }
                    .padding(20)
                }//ScrollView
            }
            
            if isShowingBackAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingBackAlert, viewType: .writingCancel) {
                    isShowingCreate.toggle()
                }
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .never
            
            if !isNewProduct {
                if let trade = trade {
                    self.title = trade.title
                    self.myProduct = trade.myProduct
                    self.category = trade.category
                    self.wantProduct = trade.wantProduct ?? ""
                    self.content = trade.content
                }
            }
        }
        .onTapGesture {
            withAnimation {
                self.isShowingCategoryMenuList = false
                self.isShowingLocationMenuList = false
            }
        }
    }
}

#Preview {
    TradeCreateView(isShowingCreate: .constant(true), isNewProduct: true)
        .environmentObject(TradeViewModel())
}
