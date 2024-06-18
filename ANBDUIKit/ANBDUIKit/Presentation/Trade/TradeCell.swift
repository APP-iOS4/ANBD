//
//  TradeCell.swift
//  ANBDUIKit
//
//  Created by 최정인 on 6/15/24.
//

import Foundation
import UIKit
import SnapKit

final class TradeCell: UITableViewCell {
    
    static let identifier = "TradeCell"
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let heartStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let thumbnailImageView: UIImageView = {
        let image = UIImage(named: "DummyPuppy2")
        let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = image
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .left
        return label
    }()
    
    private let heartImageView: UIImageView = {
        let view = UIImageView(frame: .init(x: 0, y: 0, width: 28, height: 30))
        view.image = .init(systemName: "heart")
        view.tintColor = .lightGray
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        titleLabel.text = "감딸기표 단팥빵 나눔합니다 !!!"
        infoLabel.text = "서울 · 지난주"
    }
    
    private func initLayout() {
        [containerStackView, divider].forEach {
            contentView.addSubview($0)
        }
        
        [thumbnailImageView, infoStackView].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        [UIView(), heartImageView].forEach {
            heartStackView.addArrangedSubview($0)
        }
        
        [titleLabel, UIView(), infoLabel, UIView(), heartStackView].forEach {
            infoStackView.addArrangedSubview($0)
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
        
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }
}
