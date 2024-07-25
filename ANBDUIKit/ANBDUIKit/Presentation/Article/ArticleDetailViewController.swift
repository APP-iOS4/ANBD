//
//  ArticleDetailViewController.swift
//  ANBDUIKit
//
//  Created by 유지호 on 6/4/24.
//

import UIKit

final class ArticleDetailViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    
    private let profileView = UIView()
    private lazy var profileImageView = UIImageView()
    private lazy var profileNicknameLabel = UILabel()
    private lazy var profileWriteDateLabel = UILabel()
    
    private lazy var titleLabel = UILabel()
    private lazy var contentLabel = UILabel()
    
    private var imageButtonList: [UIButton] = []
    
    private let likeCountView = UIView()
    private lazy var likeCountButton = UIButton()
    private lazy var likeCountLabel = UILabel()
    
    let imageList = [0, 1, 2, 3, 4]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        contentStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()
        
        profileImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = .lightGray
            imageView.layer.cornerRadius = 20
            return imageView
        }()
        
        profileNicknameLabel = {
            let label = UILabel()
            label.text = "작성자 닉네임"
            return label
        }()
        
        profileWriteDateLabel = {
            let label = UILabel()
            label.text = "작성 날짜"
            return label
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "글 제목"
            label.numberOfLines = 2
            return label
        }()
        
        contentLabel = {
            let label = UILabel()
            label.text = "글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용 글 내용"
            label.numberOfLines = 0
            return label
        }()
        
        makeImageButtons()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let keyboardLayout = view.keyboardLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        [profileView, titleLabel, contentLabel, UIView()].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        imageButtonList.forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        [profileImageView, profileNicknameLabel, profileWriteDateLabel].forEach {
            profileView.addSubview($0)
        }
                
        scrollView.snp.makeConstraints {
            $0.horizontalEdges.top.equalTo(safeArea)
            $0.bottom.equalTo(keyboardLayout.snp.top)
        }
        
        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.verticalEdges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide).offset(-32)
//            $0.height.equalTo(view)
        }
        
        profileImageView.snp.makeConstraints {
            $0.left.verticalEdges.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        profileNicknameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right)
            $0.top.equalTo(profileImageView)
        }
        
        profileWriteDateLabel.snp.makeConstraints {
            $0.left.equalTo(profileNicknameLabel)
            $0.top.equalTo(profileNicknameLabel.snp.bottom).offset(4)
        }
        
        imageButtonList.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(300)
            }
        }
    }
    
    private func makeImageButtons() {
        for i in 0..<imageList.count {
            let button = UIButton()
            button.setTitle("이미지 \(i + 1)", for: .normal)
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 8
            button.tag = i
            button.addTarget(self, action: #selector(tapImage), for: .touchUpInside)
            imageButtonList.append(button)
        }
    }
    
    @objc
    private func tapImage(_ sender: UIButton) {
        print(sender.tag)
    }
    
}
