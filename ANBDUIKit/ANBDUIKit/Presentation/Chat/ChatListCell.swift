//
//  ChatListCell.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/3/24.
//

import UIKit
import SnapKit

final class ChatListCell: UITableViewCell {
    
    static let identifier = "ChatListCell"
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let profileImageView: UIImageView = {
        let image = UIImage(named: "DefaultUserProfileImage.001")
        let imageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true

        return imageView
    }()
    
    private let nameContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let dateBadgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .left
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()
    
    private var badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.backgroundColor = .red
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        nameLabel.text = "쭈리"
        contentLabel.text = "나눠주신 물건 잘 받았습니다. 감사합니다."
        dateLabel.text = "7월 3일"
        badgeLabel.text = "2"
    }
    
    private func initLayout() {

        contentView.addSubview(containerStackView)
        
        [profileImageView, nameContentStackView, dateBadgeStackView].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        [nameLabel, contentLabel].forEach {
            nameContentStackView.addArrangedSubview($0)
        }
        
        [dateLabel, badgeLabel].forEach {
            dateBadgeStackView.addArrangedSubview($0)
        }
        
        containerStackView.snp.makeConstraints {
            $0.right.equalToSuperview().inset(20)
            $0.left.equalToSuperview().inset(5)
            $0.verticalEdges.equalToSuperview().inset(15)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
    }
}
