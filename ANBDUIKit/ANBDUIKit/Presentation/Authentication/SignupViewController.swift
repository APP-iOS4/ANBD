//  SignupViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 7/7/24.
//

import UIKit
import SnapKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 주소"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
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
    
    private let checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "이미 계정이 있으신가요?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
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
        setupViews()
        setupConstraints()
        
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(signupLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailDivider)
        view.addSubview(checkButton)
        view.addSubview(loginLabel)
        view.addSubview(loginButton)
        view.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        signupLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalTo(view).inset(20)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(signupLabel.snp.bottom).offset(50)
            $0.leading.equalTo(view).inset(20)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(5)
            $0.leading.equalTo(view).inset(20)
            $0.trailing.equalTo(checkButton.snp.leading).offset(-10)
            $0.height.equalTo(44)
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalTo(emailTextField)
            $0.trailing.equalTo(view).inset(20)
            $0.width.equalTo(65)
            $0.height.equalTo(35)
        }
        
        emailDivider.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(1)
        }
        
        loginLabel.snp.makeConstraints {
            $0.top.equalTo(emailDivider.snp.bottom).offset(20)
            $0.centerX.equalTo(view).offset(-30)
        }
        
        loginButton.snp.makeConstraints {
            $0.leading.equalTo(loginLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(loginLabel)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        let isEmailNotEmpty = !(emailTextField.text ?? "").isEmpty
        checkButton.isEnabled = isEmailNotEmpty
        checkButton.alpha = isEmailNotEmpty ? 1.0 : 0.5
    }
    
    @objc private func checkButtonTapped() {
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }
    
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func nextButtonTapped() {
        let passwordVC = PasswordViewController()
        navigationController?.pushViewController(passwordVC, animated: true)
    }
}
