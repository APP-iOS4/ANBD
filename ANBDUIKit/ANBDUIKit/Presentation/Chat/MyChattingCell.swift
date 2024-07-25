//
//  ChattingCell.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/18/24.
//

import UIKit

final class MyChattingCell: UITableViewCell {
    
    static let identifier = "MyChattingCell"
    
    private lazy var messageStack: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .trailing
        stackView.spacing = 8
        return stackView
    }()
    
    private var messageLabel: BasePaddingLabel = {
        let label = BasePaddingLabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.backgroundColor = .systemCyan
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
        
        messageStack.addArrangedSubview(dateLabel)
        messageStack.addArrangedSubview(messageLabel)
        
        messageStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.right.equalToSuperview().inset(35)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        messageLabel.text = "거래 원해요~~!가나다라마바사"
        dateLabel.text = "오후 9:29"
    }
}

class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}
