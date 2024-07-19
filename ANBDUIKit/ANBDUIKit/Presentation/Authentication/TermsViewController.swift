//
//  TermsViewController.swift
//  ANBDUIKit
//
//  Created by 기 표 on 7/17/24.
//

import UIKit
import SnapKit

class TermsViewController: UIViewController {
    
    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "ANBD\n서비스 이용 약관"
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let termsDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let allAgreeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: image), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(allAgreeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let allAgreeLabel: UILabel = {
        let label = UILabel()
        label.text = "모두 동의 (선택 정보 포함)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let ageButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: image), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(otherButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "만 14세 이상입니다. (필수)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let termsButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: image), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(otherButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let termsLabel2: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용약관에 동의 (필수)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: image), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(otherButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 수집 및 이용에 동의 (필수)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let marketingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: image), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(otherButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let marketingLabel: UILabel = {
        let label = UILabel()
        label.text = "광고 및 마케팅 수신에 동의 (선택)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입 완료", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
//        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(signupLabel)
        view.addSubview(termsLabel)
        view.addSubview(allAgreeButton)
        view.addSubview(allAgreeLabel)
        view.addSubview(ageButton)
        view.addSubview(ageLabel)
        view.addSubview(termsButton)
        view.addSubview(termsLabel2)
        view.addSubview(privacyButton)
        view.addSubview(privacyLabel)
        view.addSubview(marketingButton)
        view.addSubview(marketingLabel)
        view.addSubview(termsDivider)
        view.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        signupLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalTo(view).inset(20)
        }
        
        termsLabel.snp.makeConstraints {
            $0.top.equalTo(signupLabel.snp.bottom).offset(50)
            $0.leading.equalTo(view).inset(20)
            $0.trailing.equalTo(view).inset(20)
        }
        
        allAgreeButton.snp.makeConstraints {
            $0.top.equalTo(termsLabel.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
            $0.width.height.equalTo(24)
        }
        
        allAgreeLabel.snp.makeConstraints {
            $0.leading.equalTo(allAgreeButton.snp.trailing).offset(10)
            $0.centerY.equalTo(allAgreeButton)
            $0.trailing.equalTo(view).inset(20)
        }
        
        termsDivider.snp.makeConstraints {
            $0.top.equalTo(allAgreeLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(1)
        }
        
        ageButton.snp.makeConstraints {
            $0.top.equalTo(termsDivider.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
            $0.width.height.equalTo(24)
        }
        
        ageLabel.snp.makeConstraints {
            $0.leading.equalTo(ageButton.snp.trailing).offset(10)
            $0.centerY.equalTo(ageButton)
            $0.trailing.equalTo(view).inset(20)
        }
        
        termsButton.snp.makeConstraints {
            $0.top.equalTo(ageLabel.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
            $0.width.height.equalTo(24)
        }
        
        termsLabel2.snp.makeConstraints {
            $0.leading.equalTo(termsButton.snp.trailing).offset(10)
            $0.centerY.equalTo(termsButton)
            $0.trailing.equalTo(view).inset(20)
        }
        
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(termsLabel2.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
            $0.width.height.equalTo(24)
        }
        
        privacyLabel.snp.makeConstraints {
            $0.leading.equalTo(privacyButton.snp.trailing).offset(10)
            $0.centerY.equalTo(privacyButton)
            $0.trailing.equalTo(view).inset(20)
        }
        
        marketingButton.snp.makeConstraints {
            $0.top.equalTo(privacyLabel.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
            $0.width.height.equalTo(24)
        }
        
        marketingLabel.snp.makeConstraints {
            $0.leading.equalTo(marketingButton.snp.trailing).offset(10)
            $0.centerY.equalTo(marketingButton)
            $0.trailing.equalTo(view).inset(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(marketingLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
    }
    
    @objc private func allAgreeButtonTapped() {
        let isSelected = allAgreeButton.currentImage == UIImage(systemName: "checkmark.circle.fill")
        let newImage = UIImage(systemName: isSelected ? "checkmark.circle" : "checkmark.circle.fill")
        allAgreeButton.setImage(newImage, for: .normal)
        
        let buttons = [ageButton, termsButton, privacyButton, marketingButton]
        for button in buttons {
            button.setImage(newImage, for: .normal)
        }
    }
    
    @objc private func otherButtonTapped(_ sender: UIButton) {
        let isSelected = sender.currentImage == UIImage(systemName: "checkmark.circle.fill")
        let newImage = UIImage(systemName: isSelected ? "checkmark.circle" : "checkmark.circle.fill")
        sender.setImage(newImage, for: .normal)
        
        updateAllAgreeButtonState()
    }
    
    private func updateAllAgreeButtonState() {
        let buttons = [ageButton, termsButton, privacyButton, marketingButton]
        let allSelected = buttons.allSatisfy { $0.currentImage == UIImage(systemName: "checkmark.circle.fill") }
        let newImage = UIImage(systemName: allSelected ? "checkmark.circle.fill" : "checkmark.circle")
        allAgreeButton.setImage(newImage, for: .normal)
    }
    
    @objc private func nextButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
