//
//  LoadingView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/29/24.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading")
                .font(ANBDFont.body1)
                .fontWeight(.semibold)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white.opacity(0.5))
    }
}

#Preview {
    LoadingView()
}
