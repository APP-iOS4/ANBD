//
//  ImageDetailView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI

struct ImageDetailView: View {
    @Binding var imageString: String
    @Binding var isShowingImageDetailView: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isShowingImageDetailView.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                })
                .padding(.horizontal)
                
                Spacer()
            }
            Spacer()
            
            Image(imageString)
                .resizable()
                .scaledToFit()
            
            Spacer()
        }
        .background(.black.opacity(0.95))
        .onAppear {
            print("여긴 ImageDetailView : \(imageString)")
        }
    }
}

#Preview {
    NavigationStack {
        ImageDetailView(imageString: .constant("DummyPuppy1"), isShowingImageDetailView: .constant(true))
    }
}
