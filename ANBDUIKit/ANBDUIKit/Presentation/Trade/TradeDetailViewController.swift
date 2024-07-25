//
//  TradeDetailViewController.swift
//  ANBDUIKitTest
//
//  Created by 최정인 on 6/1/24.
//

import UIKit
import SnapKit

final class TradeDetailViewController: UIViewController {
    
    private var wholeStackView = UIStackView()
    
    private var detailImageView = UIImageView()
    
    private var profileStackView = UIStackView()
    private var profileInfoStackView = UIStackView()
    private var profileImageView = UIImageView()
    private var nickname = UILabel()
    private var dateLabel = UILabel()
    
    private var tradeDetailStackView = UIStackView()
    private var tradeTitle = UILabel()
    private var tradeSubTitle = UILabel()
    private var tradeDescription = UILabel()
    
    private var footerStackView = UIStackView()
    private var heartButton = UIButton()
    private var productTitle = UILabel()
    
    private var divider1 = UIView()
    private var divider2 = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        wholeStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            return stackView
        }()
        
        /// image
        detailImageView = {
            let image = UIImage(named: "DummyPuppy")
            let resizedImage = image?.resized(to: CGSize(width: view.frame.width, height: 300))
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = resizedImage
            return imageView
        }()
        
        /// profile
        profileStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 10
            return stackView
        }()
        
        profileImageView = {
            let image = UIImage(named: "DummyPuppy2")
            let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
            imageView.layer.cornerRadius = 25
            imageView.clipsToBounds = true
            imageView.image = image
            return imageView
        }()
        
        profileInfoStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        
        nickname = {
            let label = UILabel()
            label.text = "환경순찰대"
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            label.text = "지난주"
            label.font = .systemFont(ofSize: 15)
            label.textColor = .systemGray
            return label
        }()
        
        /// Trade Detail
        tradeDetailStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 5
            return stackView
        }()
        
        tradeTitle = {
            let label = UILabel()
            label.text = "단팥빵 나눔해요~!"
            label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            label.textAlignment = .left
            return label
        }()
        
        tradeSubTitle = {
            let label = UILabel()
            label.text = "기타 중고물품 · 서울"
            label.font = .systemFont(ofSize: 15)
            label.textColor = .systemGray
            return label
        }()
        
        tradeDescription = {
            let label = UILabel()
            label.text = "이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 이거는 나눔거래의 상세설명이걸랑요 상세설명 "
            label.numberOfLines = 0
            return label
        }()
        
        ///
        footerStackView = {
            let stackView = UIStackView()
            stackView.axis = . horizontal
            return stackView
        }()
        
        heartButton = {
            let button = UIButton(frame: .init(x: 0, y: 0, width: 28, height: 30))
            button.setImage(UIImage(systemName: "heart"), for: .normal)
            button.tintColor = .lightGray
            button.addTarget(self, action: #selector(tapHeartButton), for: .touchUpInside)
            return button
        }()
        
        productTitle = {
            let label = UILabel()
            label.text = "단팥빵"
            label.font = UIFont.preferredFont(forTextStyle: .headline)
            return label
        }()
        
        divider1 = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
        }()
        
        divider2 = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
        }()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(detailImageView)
        view.addSubview(wholeStackView)
        
        detailImageView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
        }
        
        wholeStackView.snp.makeConstraints {
            $0.top.equalTo(detailImageView.snp.bottom).offset(10)
        }
        
        [profileStackView, divider1, tradeDetailStackView, UIView(), divider2, footerStackView].forEach {
            wholeStackView.addArrangedSubview($0)
        }
        
        [profileImageView, profileInfoStackView, UIView()].forEach {
            profileStackView.addArrangedSubview($0)
        }
        
        [nickname, dateLabel].forEach {
            profileInfoStackView.addArrangedSubview($0)
        }
        
        [tradeTitle, tradeSubTitle, UIView(), tradeDescription].forEach {
            tradeDetailStackView.addArrangedSubview($0)
        }
        
        [heartButton, UIView(), productTitle, UIView()].forEach {
            footerStackView.addArrangedSubview($0)
        }
        
        footerStackView.snp.makeConstraints {
            $0.bottom.equalTo(safeArea)
        }
        
        profileStackView.snp.makeConstraints {
            $0.leading.equalTo(safeArea).offset(10)
            $0.trailing.equalTo(safeArea).offset(-10)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
        
        tradeDetailStackView.snp.makeConstraints {
            $0.top.equalTo(profileStackView.snp.bottom).offset(20)
        }
        
        divider1.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view)
            $0.height.equalTo(1)
            $0.bottom.equalTo(tradeDetailStackView.snp.top).offset(-20)
        }
        
        divider2.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view)
            $0.height.equalTo(1)
        }
        
        productTitle.snp.makeConstraints {
            $0.leading.equalTo(heartButton.snp.trailing).offset(10)
        }
        
        tradeDescription.snp.makeConstraints {
            $0.top.equalTo(tradeSubTitle.snp.bottom).offset(20)
        }
    }
    
    @objc
    private func tapHeartButton() {
        if heartButton.tintColor == .red {
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            heartButton.tintColor = .lightGray
        } else {
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            heartButton.tintColor = .red
        }
    }
}
