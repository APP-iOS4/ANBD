//
//  TradeCreateView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/8/24.
//

import SwiftUI
import ANBDModel
import PhotosUI

struct TradeCreateView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @Binding var isShowingCreate: Bool
    @State var category: Category = .nanua
    @State private var placeHolder: String = ""
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    //B
    @State private var myProduct: String = ""
    @State private var wantProduct: String = ""
    
    //photo
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    //update
    var isNewProduct: Bool = true
    var trade: Trade?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    
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
                }
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
                
                //제목
                VStack(alignment: .leading) {
                    Text("제목")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    
                    TextField("제목", text: $title)
                        .modifier(TextFieldModifier())
                        .onAppear() {
                            if !isNewProduct {
                                if let trade = trade {
                                    self.title = trade.title
                                }
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
                //거래 방식
                VStack(alignment: .leading) {
                    Text("거래 방식")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    VStack {
                        //나눠쓰기
                        if category == .nanua {
                            HStack {
                                CapsuleButtonView(text: "나눠쓰기", buttonColor: .accent, fontColor: .white)
                                
                                CapsuleButtonView(text: "바꿔쓰기")
                                    .onTapGesture {
                                        self.category = .baccua
                                    }
                                Rectangle()
                                    .frame(width: 100, height: 0)
                            }
                            .padding(.bottom, 10)
                            
                            HStack {
                                TextField("나눌 물건", text: $myProduct)
                                    .modifier(TextFieldModifier())
                                    .onAppear() {
                                        if !isNewProduct {
                                            if let trade = trade {
                                                self.myProduct = trade.myProduct ?? "Unknown"
                                            }
                                        }
                                    }
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
                                    .onAppear() {
                                        if !isNewProduct {
                                            if let trade = trade {
                                                self.myProduct = trade.myProduct ?? "Unknown"
                                            }
                                        }
                                    }
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
            }//ScrollView
        }
    }
}

#Preview {
    TradeCreateView(isShowingCreate: .constant(true), isNewProduct: true)
}
