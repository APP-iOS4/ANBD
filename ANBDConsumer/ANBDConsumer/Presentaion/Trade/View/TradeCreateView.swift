import SwiftUI
import ANBDModel
import PhotosUI

struct TradeCreateView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @StateObject private var coordinator = Coordinator.shared
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
    @State private var tmpSelectedData: [Data] = []
    @State private var selectedPhotosData: [Data] = []
    @State private var deletedPhotosData: [Int] = []
    
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
        NavigationStack {
            if #available(iOS 17.0, *) {
                wholeView
                    .onChange(of: mustTextFields, {
                        if (self.tmpSelectedData.count != 0 || self.selectedPhotosData.count != 0) && self.title != "" && self.myProduct != "" && self.content != "" {
                            self.isFinished = false
                        } else {
                            self.isFinished = true
                        }
                        // 공백입력 시 저장 x
                        for item in mustTextFields {
                            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item == "" {
                                isFinished = true
                            }
                        }
                    })
                
                    .onChange(of: selectedPhotosData, {
                        if (self.tmpSelectedData.count != 0 || self.selectedPhotosData.count != 0) && self.title != "" && self.myProduct != "" && self.content != "" {
                            self.isFinished = false
                        } else {
                            self.isFinished = true
                        }
                        
                        // 공백입력 시 저장 x
                        for item in mustTextFields {
                            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item == "" {
                                isFinished = true
                            }
                        }
                        
                        isCancelable = false
                    })
                
                    .onChange(of: tmpSelectedData, {
                        if tmpSelectedData.count != tradeViewModel.trade.imagePaths.count {
                            if (self.tmpSelectedData.count != 0 || self.selectedPhotosData.count != 0) && self.title != "" && self.myProduct != "" && self.content != "" {
                                self.isFinished = false
                            } else {
                                self.isFinished = true
                            }
                            
                            // 공백입력 시 저장 x
                            for item in mustTextFields {
                                if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item == "" {
                                    isFinished = true
                                }
                            }
                            
                            isCancelable = false
                        }
                    })
                
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
                wholeView
                    .onChange(of: mustTextFields) { _ in
                        if (self.tmpSelectedData.count != 0 || self.selectedPhotosData.count != 0) && self.title != "" && self.myProduct != "" && self.content != "" {
                            self.isFinished = false
                        } else {
                            self.isFinished = true
                        }
                        
                        //                        // 공백입력 시 저장 x
                        for item in mustTextFields {
                            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item == "" {
                                isFinished = true
                            }
                        }
                    }
                
                    .onChange(of: selectedPhotosData) { _ in
                        if (self.tmpSelectedData.count != 0 || self.selectedPhotosData.count != 0) && self.title != "" && self.myProduct != "" && self.content != "" {
                            self.isFinished = false
                        } else {
                            self.isFinished = true
                        }
                        
                        // 공백입력 시 저장 x
                        for item in mustTextFields {
                            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item == "" {
                                isFinished = true
                            }
                        }
                        
                        isCancelable = false
                    }
                
                    .onChange(of: tmpSelectedData) { _ in
                        if tmpSelectedData.count != tradeViewModel.trade.imagePaths.count {
                            if (self.tmpSelectedData.count != 0 || self.selectedPhotosData.count != 0) && self.title != "" && self.myProduct != "" && self.content != "" {
                                self.isFinished = false
                            } else {
                                self.isFinished = true
                            }
                            
                            // 공백입력 시 저장 x
                            for item in mustTextFields {
                                if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item == "" {
                                    isFinished = true
                                }
                            }
                            
                            isCancelable = false
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
        
    }
}

fileprivate extension TradeCreateView {
    var wholeView: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                //MARK: - 사진 선택
                
                ScrollView {
                    if #available(iOS 17.0, *) {
                        photosView
                            .onChange(of: selectedItems) {
                                Task {
                                    selectedPhotosData = []
                                    for newItem in selectedItems {
                                        
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
                                Task {
                                    selectedPhotosData = []
                                    for newItem in selectedItems {
                                        
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
                    
                    //MARK: - 제목
                    
                    VStack(alignment: .leading) {
                        Text("제목")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        
                        TextField("제목", text: $title)
                            .modifier(TextFieldModifier())
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    //MARK: - 거래 방식 선택 버튼
                    
                    if #available(iOS 17.0, *) {
                        selectCategoryView
                            .onChange(of: myProduct) {
                                if myProduct.count > 8 {
                                    myProduct = String(myProduct.prefix(8))
                                }
                            }
                            .onChange(of: wantProduct) {
                                if wantProduct.count > 8 {
                                    wantProduct = String(wantProduct.prefix(8))
                                }
                            }
                    } else {
                        selectCategoryView
                            .onChange(of: myProduct) { _ in
                                if myProduct.count > 8 {
                                    myProduct = String(myProduct.prefix(8))
                                }
                            }
                            .onChange(of: wantProduct) { _ in
                                if wantProduct.count > 8 {
                                    wantProduct = String(wantProduct.prefix(8))
                                }
                            }
                    }
                    
                    //MARK: - 카테고리 & 지역 선택
                    
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
                    
                    VStack(alignment: .leading) {
                        Text("지역")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        
                        LocationPickerMenu(isShowingMenuList: $isShowingLocationMenuList, selectedItem: $tradeViewModel.selectedLocation)
                            .onTapGesture {
                                self.isShowingCategoryMenuList = false
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    //MARK: - 상세 설명
                    
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
                }//ScrollView
                
                //MARK: - 작성 완료 / 수정 완료 버튼
                
                BlueSquareButton(title: isNewProduct ? "작성 완료" : "수정 완료", isDisabled: isFinished) {
                    if isNewProduct {
                        coordinator.isLoading = true
                        
                        Task {
                            await tradeViewModel.createTrade(category: category, itemCategory: tradeViewModel.selectedItemCategory, location: tradeViewModel.selectedLocation, title: title, content: content, myProduct: myProduct, wantProduct: wantProduct, images: selectedPhotosData)
                            
                            await tradeViewModel.reloadFilteredTrades(category: category)
                            
                            tradeViewModel.selectedLocation = .seoul
                            tradeViewModel.selectedItemCategory = .digital
                            
                            coordinator.isLoading = false
                            self.isShowingCreate.toggle()
                        }
                    } else {
                        coordinator.isLoading = true
                        
                        if let trade {
                            Task {
                                await tradeViewModel.updateTrade(category: category, title: title, content: content, myProduct: myProduct, wantProduct: wantProduct, addImages: selectedPhotosData, deletedImagesIndex: deletedPhotosData)
                                await tradeViewModel.loadOneTrade(trade: trade)
                                
                                tradeViewModel.selectedLocation = .seoul
                                tradeViewModel.selectedItemCategory = .digital
                                
                                coordinator.isLoading = false
                                self.isShowingCreate.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
            
            if isShowingBackAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingBackAlert, viewType: .writingCancel) {
                    tradeViewModel.selectedLocation = .seoul
                    tradeViewModel.selectedItemCategory = .digital
                    isShowingCreate.toggle()
                }
            }
            
            if coordinator.isLoading {
                LoadingView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal, content: {
                if isNewProduct {
                    Text("새 상품 등록")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                } else {
                    Text("상품 수정")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                }
            })
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    endTextEditing()
                    
                    // 수정: 바뀐 정보가 있다면 backAlert
                    if let trade = trade {
                        if self.title != trade.title || self.content != trade.content || self.category != trade.category || self.myProduct != trade.myProduct || tradeViewModel.selectedItemCategory != trade.itemCategory || tradeViewModel.selectedLocation != trade.location {
                            isCancelable = false
                        } else {
                            isFinished = false
                        }
                    } else {
                        // 새로 작성: 쓰여진 필드가 있다면 backAleart
                        for item in mustTextFields {
                            if item != "" {
                                isCancelable = false
                            }
                        }
                    }
                    
                    if isCancelable {
                        //지역은 user 선호 지역으로 선택되게
                        tradeViewModel.selectedLocation = UserStore.shared.user.favoriteLocation
                        tradeViewModel.selectedItemCategory = .digital
                        isShowingCreate.toggle()
                    } else {
                        isShowingBackAlert.toggle()
                    }
                } label: {
                    Text("취소")
                }
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .never
            
            if !isNewProduct {
                guard let trade else { return }
                
                self.title = trade.title
                self.myProduct = trade.myProduct
                self.category = trade.category
                self.wantProduct = trade.wantProduct ?? ""
                self.content = trade.content
                self.itemCategory = trade.itemCategory
                self.location = trade.location
                Task {
                    tmpSelectedData = try await tradeViewModel.loadDetailImages(path: .trade, containerID: trade.id, imagePath: trade.imagePaths)
                }
                //self.isFinished = false
            }
        }
        .onTapGesture {
            withAnimation {
                self.isShowingCategoryMenuList = false
                self.isShowingLocationMenuList = false
            }
        }
    }
    
    var photosView: some View {
        HStack {
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 5 - tmpSelectedData.count, matching: .images) {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(.gray)
                        .padding(3)
                    Text("\(selectedItems.count + tmpSelectedData.count) / 5")
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
                    ForEach(tmpSelectedData, id: \.self) {photoData in
                        ZStack(alignment:.topTrailing){
                            
                            if let image = UIImage(data: photoData) {
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width : 80 , height: 80)
                                    .cornerRadius(10)
                                    .clipped()
                                    .padding(5)
                            }
                            
                            Circle()
                                .overlay (
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.black)
                                )
                                .foregroundStyle(.white)
                                .frame(width: 20, height:20)
                                .onTapGesture {
                                    if let idx = tmpSelectedData.firstIndex(of: photoData) {
                                        //deletedPhotosData.append(tmpSelectedData[idx])
                                        deletedPhotosData.append(idx)
                                        tmpSelectedData.remove(at: idx)
                                    }
                                }
                        }
                    }
                    ForEach(selectedPhotosData, id: \.self) { photoData in
                        ZStack(alignment:.topTrailing){
                            
                            if let image = UIImage(data: photoData) {
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width : 80 , height: 80)
                                    .cornerRadius(10)
                                    .clipped()
                                    .padding(5)
                            }
                            
                            Circle()
                                .overlay (
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.black)
                                )
                                .foregroundStyle(.white)
                                .frame(width: 20, height:20)
                                .onTapGesture {
                                    if let idx = selectedPhotosData.firstIndex(of: photoData) {
                                        selectedPhotosData.remove(at: idx)
                                        selectedItems.remove(at: idx)
                                    }
                                }
                        }
                    }
                }
                .padding(.bottom, 30)
            }//Horizontal ScrollView
            .padding(.horizontal, 10)
        }
    }
    
    var selectCategoryView: some View {
        VStack(alignment: .leading) {
            Text("거래 방식")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .padding(.bottom, 10)
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
    }
}

#Preview {
    TradeCreateView(isShowingCreate: .constant(true), isNewProduct: true)
        .environmentObject(TradeViewModel())
}
