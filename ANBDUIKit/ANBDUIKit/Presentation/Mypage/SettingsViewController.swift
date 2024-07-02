//
//  SettingsViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/16/24.
//

import UIKit
import SnapKit
import SafariServices

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

        let blockedUserListButton = createButton(title: "차단 사용자 관리")
        blockedUserListButton.addTarget(self, action: #selector(blockUserListButtonTapped), for: .touchUpInside)

        let otherSettingsLabel = createLabel(text: "기타")
        let termsPoliciesButton = createButton(title: "약관 및 정책")
        termsPoliciesButton.addTarget(self, action: #selector(termsPoliciesButtonTapped), for: .touchUpInside)

        let openSourceLicenseButton = createButton(title: "오픈소스 라이선스")
        openSourceLicenseButton.addTarget(self, action: #selector(openSourceLicenseButtonTapped), for: .touchUpInside)

        let clearCacheButton = createButtonWithDetail(title: "캐시 데이터 삭제하기", detail: "1.123 MB")
        clearCacheButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearCacheButtonTapped)))
        
        let appVersionButton = createButtonWithDetail(title: "앱 버전", detail: "1.0.0")
        let contactEmailButton = createButtonWithEmailDetail(title: "문의 메일", email: "rlvy0513@naver.com")
        let logoutButton = createButton(title: "로그아웃")
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        let deleteAccountButton = createButton(title: "회원탈퇴")
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        
        view.addSubview(userSettingsLabel)
        view.addSubview(editUserInfoButton)
        view.addSubview(blockedUserListButton)
        
        view.addSubview(otherSettingsLabel)
        view.addSubview(termsPoliciesButton)
        view.addSubview(openSourceLicenseButton)
        view.addSubview(clearCacheButton)
        view.addSubview(appVersionButton)
        view.addSubview(contactEmailButton)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        
        addDivider(below: blockedUserListButton)
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

    @objc private func blockUserListButtonTapped() {
        let blockUserList = BlockUserListViewController()
        blockUserList.title = "차단 사용자 관리"
        navigationController?.pushViewController(blockUserList, animated: true)
    }
    
    @objc private func termsPoliciesButtonTapped() {
        openSafariViewController(urlString: "https://oval-second-abc.notion.site/ANBD-036716b1ef784b019ab0df8147bd4e65")
    }
    
    @objc private func openSourceLicenseButtonTapped() {
        openSafariViewController(urlString: "https://oval-second-abc.notion.site/97ddaf4813f7481a84c36ff4f3c3faef")
    }
    
    @objc private func clearCacheButtonTapped() {
        presentSingleButtonAlert(title: "캐시 삭제 완료", message: "캐시 데이터가 삭제되었습니다.", buttonText: "확인", buttonColor: .systemBlue)
    }

    @objc private func logoutButtonTapped() {
        presentAlert(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", buttonText: "로그아웃", buttonColor: .systemRed)
    }
    
    @objc private func deleteAccountButtonTapped() {
        presentAlert(title: "회원탈퇴", message: "정말 ANBD를 탈퇴 하시겠습니까?\n회원 탈퇴시 회원 정보가 복구되지 않습니다.", buttonText: "탈퇴하기", buttonColor: .systemRed)
    }
    
    private func presentAlert(title: String?, message: String, buttonText: String, buttonColor: UIColor) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .destructive)
        action.setValue(buttonColor, forKey: "titleTextColor")
        alertController.addAction(action)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentSingleButtonAlert(title: String?, message: String, buttonText: String, buttonColor: UIColor) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default)
        action.setValue(buttonColor, forKey: "titleTextColor")
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    private func openSafariViewController(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
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
        
        if title == "캐시 데이터 삭제하기" {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clearCacheButtonTapped))
            button.addGestureRecognizer(tapGesture)
        }

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
