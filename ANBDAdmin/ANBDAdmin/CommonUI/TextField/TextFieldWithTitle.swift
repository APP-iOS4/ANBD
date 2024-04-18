//
//  TextFieldWithTitle.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct TextFieldWithTitle: View {
    enum FieldType {
        case normal
        case secure
    }
    
    var fieldType: FieldType
    
    var title: String
    var placeholder: String
    
    @State private var isMasked = true
    
    @Binding var inputText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title)")
                .font(ANBDFont.SubTitle3)
                .foregroundStyle(Color.gray900)
            
            if fieldType == .normal {
                TextFieldUIKit(placeholder: placeholder, text: $inputText)
                    .font(ANBDFont.body2)
                    .padding(.horizontal, 4)
            } else {
                HStack {
                    Group {
                        if isMasked {
                            SecureFieldUIKit(placeholder: placeholder, text: $inputText)
                        } else {
                            TextFieldUIKit(placeholder: placeholder, text: $inputText)
                        }
                    }
                    .font(ANBDFont.body2)
                    .padding(.horizontal, 4)
                    
                    Button(action: {
                        isMasked.toggle()
                    }, label: {
                        Image(systemName: isMasked ? "eye.slash" : "eye")
                    })
                    .frame(height: 20)
                    .tint(Color.gray400)
                }
            }
            
            Divider()
                .foregroundStyle(.gray200)
        }
    }
    
    func TextFieldUIKit(placeholder: String, text: Binding<String>) -> some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        
        return TextField(placeholder, text: text)
    }
    
    func SecureFieldUIKit(placeholder: String, text: Binding<String>) -> some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        
        return SecureField(placeholder, text: text)
    }
}
