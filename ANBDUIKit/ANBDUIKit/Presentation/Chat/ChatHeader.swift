//
//  ChatHeader.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/6/24.
//

import UIKit

final class ChatHeader: UIView {
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 15
        return stackView
    }()
    
    private let thumbnailImageView: UIImageView = {
        let image = UIImage(named: "DummyPuppy2")
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.text = "강아지사진 무료나눔 합니다"
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.text = "강아지 사진"
        label.textColor = .lightGray
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        self.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(thumbnailImageView)
        containerStackView.addArrangedSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(contentLabel)
        
        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.height.equalTo(70)
            $0.width.equalTo(70)
        }
        
        
    }
}
