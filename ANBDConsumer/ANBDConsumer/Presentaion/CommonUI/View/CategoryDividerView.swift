//
//  CategoryDividerView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/5/24.
//

import SwiftUI
import ANBDModel

struct CategoryDividerView: View {
    @Binding var category: ANBDCategory
    var isFromSearchView: Bool = false
    @Namespace private var namespace
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    //아,나,바,다 모든 카테고리 divider
                    if isFromSearchView {
                        ForEach(ANBDCategory.allCases, id: \.self) { cate in
                            categoryText(cate, geometry)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    category = cate
                                }
                        }
                    } else {
                        if category == .accua || category == .dasi {
                            categoryText(.accua, geometry)
                                .onTapGesture {
                                    category = .accua
                                }
                            categoryText(.dasi, geometry)
                                .onTapGesture {
                                    category = .dasi
                                }
                        } else {
                            categoryText(.nanua, geometry)
                                .onTapGesture {
                                    category = .nanua
                                }
                            categoryText(.baccua, geometry)
                                .onTapGesture {
                                    category = .baccua
                                }
                        }
                    }
                }//HStack
                .frame(maxWidth: .infinity)
            }//VStack
        }
    }
    
    @ViewBuilder
    func categoryText(_ cate: ANBDCategory, _ geo: GeometryProxy) -> some View {
        VStack {
            Text("\(cate.description)")
                .font(ANBDFont.SubTitle1)
                .fontWeight(.semibold)
                .foregroundStyle(category == cate ? .gray900 : .gray400)
            Rectangle()
                .fill(category == cate ? .accent : .clear)
                .frame(width: (isFromSearchView ? geo.size.width/5 : geo.size.width/3), height: 2)
        }
        .padding(.horizontal, isFromSearchView ? -15 : 20)
    }
}



#Preview {
    CategoryDividerView(category: .constant(.accua))
}
