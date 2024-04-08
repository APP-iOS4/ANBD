//
//  SignUpEmailView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct SignUpEmailView: View {
    enum FocusableField {
        case email
    }
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        VStack {
            Text("회원가입")
                .font(ANBDFont.Heading2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextFieldWithTitle(fieldType: .normal,
                               title: "이메일 주소",
                               placeholder: "예) anbd@anbd.co.kr",
                               inputText: $authenticationViewModel.signUpEmailString)
            
            HStack {
                
            }
        }
    }
}

#Preview {
    SignUpEmailView()
        .environmentObject(AuthenticationViewModel())
}
