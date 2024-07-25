//
//  YourChattingCell.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/19/24.
//

import UIKit

final class YourChattingCell: UITableViewCell {
    
    static let identifier = "YourChattingCell"
    
    private lazy var messageStack: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()
    
    private let profileImageView: UIImageView = {
        let image = UIImage(named: "DefaultUserProfileImage.001")
        let imageView = UIImageView(frame: CGRectMake(0, 0, 36, 36))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true

        return imageView
    }()
    
    private var messageLabel: BasePaddingLabel = {
        let label = BasePaddingLabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.backgroundColor = .systemGray5
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(messageStack)
        
        [profileImageView, messageLabel, dateLabel].forEach {
            messageStack.addArrangedSubview($0)
        }
        
        messageStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.left.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.left.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        messageLabel.text = "이 상품 어때요? 잘 받아보셨나요 ?"
        dateLabel.text = "오후 10:49"
    }
}
