//
//  ViewController.swift
//  ANBDUIKit
//
//  Created by 최정인 on 5/31/24.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController {
    
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let favoriteLocationLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let accuaButton = UIButton()
    private let nanuaButton = UIButton()
    private let baccuaButton = UIButton()
    private let dasiButton = UIButton()
    
    private let accuaLabel = UILabel()
    private let nanuaLabel = UILabel()
    private let baccuaLabel = UILabel()
    private let dasiLabel = UILabel()
    
    private let likedArticleButton = UIButton()
    private let likedTradeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "내 정보"
        setupNavigationBar()
        setupView()
        setupConstraints()
        
        likedArticleButton.addTarget(self, action: #selector(didTapLikedArticleButton), for: .touchUpInside)
        likedTradeButton.addTarget(self, action: #selector(didTapLikedTradeButton), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        let gearButton = UIButton(type: .custom)
        gearButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        gearButton.addTarget(self, action: #selector(didTapGearButton), for: .touchUpInside)
        
        
        
        let gearBarButtonItem = UIBarButtonItem(customView: gearButton)
        self.navigationItem.rightBarButtonItem = gearBarButtonItem
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 47.5
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.image = UIImage(named: "DefaultUserProfileImage.001")
        
        nicknameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nicknameLabel.textColor = .black
        nicknameLabel.text = "짱표"
        
        favoriteLocationLabel.font = UIFont.systemFont(ofSize: 12)
        favoriteLocationLabel.textColor = .gray
        favoriteLocationLabel.text = "선호 지역: 서울"
        
        emailLabel.font = UIFont.systemFont(ofSize: 12)
        emailLabel.textColor = .gray
        emailLabel.text = "rlvy0513@naver.com"
        
        activityInfoButton(accuaButton, title: "아껴 쓴 개수")
        activityInfoButton(nanuaButton, title: "나눠 쓴 개수")
        activityInfoButton(baccuaButton, title: "바꿔 쓴 개수")
        activityInfoButton(dasiButton, title: "다시 쓴 개수")
        
        activityInfoLabel(accuaLabel, text: "0")
        activityInfoLabel(nanuaLabel, text: "0")
        activityInfoLabel(baccuaLabel, text: "0")
        activityInfoLabel(dasiLabel, text: "0")
        
        likedArticleButton.setTitle("내가 좋아요한 게시글 보기", for: .normal)
        likedArticleButton.setTitleColor(.black, for: .normal)
        likedArticleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        likedTradeButton.setTitle("내가 찜한 나눔 ・ 거래 보기", for: .normal)
        likedTradeButton.setTitleColor(.black, for: .normal)
        likedTradeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(favoriteLocationLabel)
        view.addSubview(emailLabel)
        view.addSubview(likedArticleButton)
        view.addSubview(likedTradeButton)
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(view).offset(20)
            $0.width.height.equalTo(95)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView).offset(10)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
        }
        
        favoriteLocationLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(nicknameLabel)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(favoriteLocationLabel.snp.bottom).offset(2)
            $0.leading.equalTo(favoriteLocationLabel)
        }
        
        let buttonStackView = createButtonStackView()
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        let articleDivider2 = createDivider(width: UIScreen.main.bounds.width, height: 0.66)
        view.addSubview(articleDivider2)
        articleDivider2.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(1)
        }
        
        likedArticleButton.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(30)
            $0.leading.equalTo(nicknameLabel).offset(-100)
        }
        
        let articleDivider = createDivider(width: UIScreen.main.bounds.width, height: 0.66)
        view.addSubview(articleDivider)
        articleDivider.snp.makeConstraints {
            $0.top.equalTo(likedArticleButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(1)
        }
        
        likedTradeButton.snp.makeConstraints {
            $0.top.equalTo(articleDivider.snp.bottom).offset(10)
            $0.leading.equalTo(nicknameLabel).offset(-100)
        }
    }
    
    private func createButtonStackView() -> UIStackView {
        func createLabelStack(button: UIButton, label: UILabel) -> UIStackView {
            activityInfoButton(button, title: button.currentTitle ?? "")
            activityInfoLabel(label, text: label.text ?? "0")
            
            let stack = UIStackView(arrangedSubviews: [button, label])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 5
            
            stack.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
            stack.addGestureRecognizer(tapGesture)
            return stack
        }
        
        let accuaStack = createLabelStack(button: accuaButton, label: accuaLabel)
        let nanuaStack = createLabelStack(button: nanuaButton, label: nanuaLabel)
        let baccuaStack = createLabelStack(button: baccuaButton, label: baccuaLabel)
        let dasiStack = createLabelStack(button: dasiButton, label: dasiLabel)
        
        let buttonStackView = UIStackView(arrangedSubviews: [
            accuaStack,
            createDivider(width: 0.66, height: 55),
            nanuaStack,
            createDivider(width: 0.66, height: 55),
            baccuaStack,
            createDivider(width: 0.66, height: 55),
            dasiStack
        ])
        
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 15
        
        return buttonStackView
    }
    
    @objc private func didTapGearButton() {
        let settings = SettingsViewController()
        navigationController?.pushViewController(settings, animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UITapGestureRecognizer) {
        let items = ["아껴쓰기", "나눠쓰기", "바꿔쓰기", "다시쓰기"]
        let emptyText = ""
        let userActivityList = UserActivityListViewController(items: items, emptyText: emptyText)
        userActivityList.title = "짱표님의 ANBD"
        navigationController?.pushViewController(userActivityList, animated: true)
    }
    
    @objc private func didTapLikedArticleButton() {
        let items = ["아껴쓰기", "다시쓰기"]
        let emptyText = "좋아요한"
        let userActivityList = UserActivityListViewController(items: items, emptyText: emptyText)
        userActivityList.title = "좋아요한 게시글"
        navigationController?.pushViewController(userActivityList, animated: true)
    }
    
    @objc private func didTapLikedTradeButton() {
        let items = ["나눠쓰기", "바꿔쓰기"]
        let emptyText = "찜한"
        let userActivityList = UserActivityListViewController(items: items, emptyText: emptyText)
        userActivityList.title = "찜한 나눔 ・ 거래"
        navigationController?.pushViewController(userActivityList, animated: true)
    }
    
    private func activityInfoButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    private func activityInfoLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .systemBlue
    }
    
    private func createDivider(width: CGFloat, height: CGFloat) -> UIView {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        view.addSubview(divider)
        divider.snp.makeConstraints {
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }
        return divider
    }
}

