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
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    //아,나,바,다 모든 카테고리 divider
                    if isFromSearchView {
                        Button(action: {
                            category = .accua
                        }, label: {
                            categoryText(.accua, geometry)
                        })
                        
                        Button(action: {
                            category = .nanua
                        }, label: {
                            categoryText(.nanua, geometry)
                        })
                        
                        Button(action: {
                            category = .baccua
                        }, label: {
                            categoryText(.baccua, geometry)
                        })
                        
                        Button(action: {
                            category = .dasi
                        }, label: {
                            categoryText(.dasi, geometry)
                        })
                        
                    } else {
                        if category == .accua || category == .dasi {
                            Button(action: {
                                category = .accua
                            }, label: {
                                categoryText(.accua, geometry)
                            })
                            
                            Button(action: {
                                category = .dasi
                            }, label: {
                                categoryText(.dasi, geometry)
                            })
                        } else {
                            Button(action: {
                                category = .nanua
                            }, label: {
                                categoryText(.nanua, geometry)
                            })
                            Button(action: {
                                category = .baccua
                            }, label: {
                                categoryText(.baccua, geometry)
                            })
                        }
                    }
                }//HStack
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
                .fill(.clear)
                .frame(height: 2)
            Rectangle()
                .fill(category == cate ? .accent : .clear)
                .frame(width: (isFromSearchView ? geo.size.width/5 : geo.size.width/3), height: 2)
        }
    }
}



#Preview {
    CategoryDividerView(category: .constant(.accua))
}
