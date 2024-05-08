//
//  String+Extension.swift
//
//
//  Created by 유지호 on 4/17/24.
//

import Foundation

public extension String {
    
    func isValidateEmail() -> Bool {
        let emailRegEx = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+(?:\.com|\.net|\.co\.kr)"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
    
    func isValidatePassword() -> Bool {
        let regex = #"^(?!([A-Za-z]+|[~!@#$%^&*()_+=]+|[0-9]+)$)[A-Za-z\d~!@#$%^&*()_+=]{8,16}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func isValidateNickname() -> Bool {
        let regex = #"^[0-9a-zA-Z가-힣][0-9a-zA-Z가-힣._]{0,18}[0-9a-zA-Z가-힣]$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
}
