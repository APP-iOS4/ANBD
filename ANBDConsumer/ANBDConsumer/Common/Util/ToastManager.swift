//
//  ToastManager.swift
//  ANBDConsumer
//
//  Created by 김성민 on 5/1/24.
//

import Foundation
import SwiftUI

final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toast: Toast? = nil
    
    private init() { }
}

struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3
    var feedbackGenerator = true
}

enum ToastStyle {
    case error
    case warning
    case success
    case info
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.red
        case .warning: return Color.orange
        case .info: return Color.blue
        case .success: return Color.accent
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: 32)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) { value in
                showToast()
            }
    }
    
    @ViewBuilder
    func mainToastView() -> some View {
        if let toast {
            VStack {
                ToastView(
                    style: toast.style,
                    message: toast.message
                )
                
                Spacer()
            }
        }
    }
    
    private func showToast() {
        guard let toast else { return }
        
        if toast.feedbackGenerator {
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}
