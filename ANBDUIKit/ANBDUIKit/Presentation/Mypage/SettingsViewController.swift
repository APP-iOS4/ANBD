//
//  SettingsViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/16/24.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "설정"
        
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        let userSettingsLabel = createLabel(text: "사용자 설정")
        let editUserInfoButton = createButton(title: "유저 정보 수정")
        editUserInfoButton.addTarget(self, action: #selector(editUserInfoButtonTapped), for: .touchUpInside)

        let blockedUsersButton = createButton(title: "차단 사용자 관리")
        
        let otherSettingsLabel = createLabel(text: "기타")
        let termsPoliciesButton = createButton(title: "약관 및 정책")
        let openSourceLicenseButton = createButton(title: "오픈소스 라이선스")
        let clearCacheButton = createButtonWithDetail(title: "캐시 데이터 삭제하기", detail: "1.123 MB")
        let appVersionButton = createButtonWithDetail(title: "앱 버전", detail: "1.0.0")
        let contactEmailButton = createButtonWithEmailDetail(title: "문의 메일", email: "rlvy0513@naver.com")
        let logoutButton = createButton(title: "로그아웃")
        let deleteAccountButton = createButton(title: "회원탈퇴")
        
        view.addSubview(userSettingsLabel)
        view.addSubview(editUserInfoButton)
        view.addSubview(blockedUsersButton)
        
        view.addSubview(otherSettingsLabel)
        view.addSubview(termsPoliciesButton)
        view.addSubview(openSourceLicenseButton)
        view.addSubview(clearCacheButton)
        view.addSubview(appVersionButton)
        view.addSubview(contactEmailButton)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        
        addDivider(below: blockedUsersButton)
    }
    
    private func setupConstraints() {
        let userSettingsLabel = view.subviews[0]
        let editUserInfoButton = view.subviews[1]
        let blockedUsersButton = view.subviews[2]
        let otherSettingsLabel = view.subviews[3]
        let termsPoliciesButton = view.subviews[4]
        let openSourceLicenseButton = view.subviews[5]
        let clearCacheButton = view.subviews[6]
        let appVersionButton = view.subviews[7]
        let contactEmailButton = view.subviews[8]
        let logoutButton = view.subviews[9]
        let deleteAccountButton = view.subviews[10]
        
        userSettingsLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(15)
        }
        
        editUserInfoButton.snp.makeConstraints {
            $0.top.equalTo(userSettingsLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        blockedUsersButton.snp.makeConstraints {
            $0.top.equalTo(editUserInfoButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        otherSettingsLabel.snp.makeConstraints {
            $0.top.equalTo(blockedUsersButton.snp.bottom).offset(35)
            $0.leading.equalTo(view).inset(20)
            $0.height.equalTo(40)
        }
        
        termsPoliciesButton.snp.makeConstraints {
            $0.top.equalTo(otherSettingsLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        openSourceLicenseButton.snp.makeConstraints {
            $0.top.equalTo(termsPoliciesButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        clearCacheButton.snp.makeConstraints {
            $0.top.equalTo(openSourceLicenseButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        appVersionButton.snp.makeConstraints {
            $0.top.equalTo(clearCacheButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        contactEmailButton.snp.makeConstraints {
            $0.top.equalTo(appVersionButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(contactEmailButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
    }
    
    @objc private func editUserInfoButtonTapped() {
        let editProfile = EditProfileViewController()
        let navigationController = UINavigationController(rootViewController: editProfile)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.textColor = .black
        
        return label
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .light)
        button.contentHorizontalAlignment = .left
        return button
    }
    
    private func createButtonWithDetail(title: String, detail: String) -> UIStackView {
        let button = createButton(title: title)
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = .darkGray
        detailLabel.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        
        let stackView = UIStackView(arrangedSubviews: [button, detailLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }
    
    private func createButtonWithEmailDetail(title: String, email: String) -> UIStackView {
        let button = createButton(title: title)
        let emailLabel = UILabel()
        emailLabel.text = email
        emailLabel.textColor = .systemBlue
        emailLabel.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        
        let stackView = UIStackView(arrangedSubviews: [button, emailLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }
    
    private func addDivider(below view: UIView, offset: CGFloat = 20) {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        self.view.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(view.snp.bottom).offset(offset)
            $0.leading.trailing.equalTo(self.view)
            $0.height.equalTo(0.6)
        }
    }
}

