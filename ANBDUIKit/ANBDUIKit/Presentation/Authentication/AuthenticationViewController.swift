//
//  AuthenticationViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 7/2/24.
//

import UIKit
import SnapKit

class AuthenticationViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ANBD"
        label.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "아껴쓰고 나눠쓰고 바꿔쓰고 다시쓰고."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let pwdLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예) anbd@anbd.co.kr"
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let emailDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "8~16자 (숫자, 영문, 특수기호 중 2개 이상)"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let passwordDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "계정이 없으신가요?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailDivider)
        view.addSubview(pwdLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordDivider)
        view.addSubview(loginButton)
        view.addSubview(signupLabel)
        view.addSubview(signupButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.centerX.equalTo(view)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalTo(view)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.leading.equalTo(view).inset(20)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
        
        emailDivider.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.leading.trailing.equalTo(emailTextField)
            $0.height.equalTo(1)
        }
        
        pwdLabel.snp.makeConstraints {
            $0.top.equalTo(emailDivider.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(pwdLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
        
        passwordDivider.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.leading.trailing.equalTo(passwordTextField)
            $0.height.equalTo(1)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(passwordDivider.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
        
        signupLabel.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(20)
            $0.centerX.equalTo(view).offset(-40)
        }
        
        signupButton.snp.makeConstraints {
            $0.leading.equalTo(signupLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(signupLabel)
        }
    }
}

extension AuthenticationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
