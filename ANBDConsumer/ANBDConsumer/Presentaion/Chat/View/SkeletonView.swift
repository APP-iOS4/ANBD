import SwiftUI

struct SkeletonView: View {
    private let size: CGSize
    @State private var isBlackBackground = true

    var backgroundColor: Color { isBlackBackground ? .black : .gray
    }
        
    init(size: CGSize) {
        self.size = size
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)
            .opacity(0.5)
            .frame(width: size.width, height: size.height)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                            .padding(1)
                    )
            )
            .overlay(content: {
                    ProgressView()
            })
            .redacted(reason: .placeholder)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isBlackBackground.toggle()
                }
            }
    }
}
