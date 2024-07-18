//
//  ChattingCell.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/18/24.
//

import UIKit

final class ChattingCell: UITableViewCell {
    
    static let identifier = "ChattingCell"
    
    private var messageBox: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .systemCyan
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.font = .preferredFont(forTextStyle: .body)
        textView.sizeToFit()
        return textView
    }()
    private lazy var dateLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(messageBox)
        contentView.addSubview(dateLabel)
        
        messageBox.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(45)
            $0.top.bottom.equalToSuperview()
            $0.width.lessThanOrEqualTo(255)
            $0.centerY.equalToSuperview()
        }
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(messageBox.snp.leading).offset(-5)
            $0.bottom.equalTo(messageBox.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        messageBox.text = "거래 원해요~~"
        dateLabel.text = "오후 9:29"
    }
}
