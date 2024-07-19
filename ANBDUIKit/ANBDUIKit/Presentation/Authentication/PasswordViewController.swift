//
//  PasswordViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 7/7/24.
//

import UIKit
import SnapKit

class PasswordViewController: UIViewController, UITextFieldDelegate {

    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "8~16자 (숫자, 영문, 특수기호 중 2개 이상)"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.returnKeyType = .next
        textField.addTarget(self, action: #selector(passwordTextFieldNotEmpty), for: .editingChanged)
        return textField
    }()
    
    private let passwordDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let passwordCheckLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let passwordCheckTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 한 번 더 입력해 주세요."
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(passwordTextFieldNotEmpty), for: .editingChanged)
        return textField
    }()
    
    private let passwordCheckDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupviews()
        setupConstraints()
        
        passwordTextField.delegate = self
        passwordCheckTextField.delegate = self
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupviews() {
        view.addSubview(signupLabel)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordDivider)
        view.addSubview(passwordCheckLabel)
        view.addSubview(passwordCheckTextField)
        view.addSubview(passwordCheckDivider)
        view.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        signupLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalTo(view).inset(20)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(signupLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalTo(view).inset(20)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
        
        passwordDivider.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.leading.trailing.equalTo(passwordTextField)
            $0.height.equalTo(1)
        }
        
        passwordCheckLabel.snp.makeConstraints {
            $0.top.equalTo(passwordDivider.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
        }
        
        passwordCheckTextField.snp.makeConstraints {
            $0.top.equalTo(passwordCheckLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
        
        passwordCheckDivider.snp.makeConstraints {
            $0.top.equalTo(passwordCheckTextField.snp.bottom)
            $0.leading.trailing.equalTo(passwordTextField)
            $0.height.equalTo(1)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(passwordCheckDivider.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
    }
    
    @objc private func passwordTextFieldNotEmpty(_ textField: UITextField) {
        let emailText = passwordTextField.text ?? ""
        let passwordText = passwordCheckTextField.text ?? ""
        let isFormValid = !emailText.isEmpty && !passwordText.isEmpty
        
        nextButton.isEnabled = isFormValid
        nextButton.alpha = isFormValid ? 1.0 : 0.5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            passwordCheckTextField.becomeFirstResponder()
        } else if textField == passwordCheckTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc private func nextButtonTapped() {
        let settingProfileVC = SettingProfileViewController()
        navigationController?.pushViewController(settingProfileVC, animated: true)
    }
}
