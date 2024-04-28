//
//  CopyableText.swift
//  ANBDAdmin
//
//  Created by sswv on 4/25/24.
//

import SwiftUI
import UIKit

struct CopyableText: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.text = text
        let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.copyText(_:)))
        label.addGestureRecognizer(gestureRecognizer)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var view: CopyableText

        init(_ view: CopyableText) {
            self.view = view
        }

        @objc func copyText(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                let pasteboard = UIPasteboard.general
                pasteboard.string = view.text
            }
        }
    }
}
