//
//  ArticleCell.swift
//  ANBDUIKit
//
//  Created by 유지호 on 6/3/24.
//

import UIKit

final class ArticleCell: UITableViewCell {
    
    static let identifier = "ArticleCell"
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    
    private let thumbImageView: UIImageView = {
        let view = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 24))
        view.image = .init(systemName: "hand.thumbsup")
        view.tintColor = .lightGray
        return view
    }()
    
    private let thumbCountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let commentImageView: UIImageView = {
        let view = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 24))
        view.image = .init(systemName: "text.bubble")
        return view
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    private var thumbCount: Int = 0 {
        didSet {
            thumbImageView.isHidden = thumbCount <= 0
            thumbCountLabel.isHidden = thumbCount <= 0
        }
    }

    private var commentCount: Int = 0 {
        didSet {
            commentImageView.isHidden = commentCount <= 0
            commentCountLabel.isHidden = commentCount <= 0
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 여기에다 모델 가지고 UI에 바인딩 해줌
    func bind() {
        titleLabel.text = "제목입니다"
        infoLabel.text = "정보가 들어갑니다"
        thumbCount = 999
        commentCount = 999
        thumbCountLabel.text = thumbCount.formatted()
        commentCountLabel.text = commentCount.formatted()
    }
    
    private func initLayout() {
        [containerStackView, divider].forEach {
            contentView.addSubview($0)
        }
        
        [articleImageView, infoStackView].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        [titleLabel, infoLabel, UIView(), countStackView].forEach {
            infoStackView.addArrangedSubview($0)
        }
        
        [UIView(), thumbImageView, thumbCountLabel, commentImageView, commentCountLabel].forEach {
            countStackView.addArrangedSubview($0)
        }
        
        containerStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(8)
        }
        
        divider.snp.makeConstraints {
            $0.horizontalEdges.equalTo(containerStackView)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        articleImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
    }
    
}
