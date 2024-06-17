//
//  NanuaCollectionViewCell.swift
//  ANBDUIKit
//
//  Created by 최주리 on 6/11/24.
//

import UIKit

final class NanuaCollectionViewCell: UICollectionViewCell {
    static let identifier = "nanuaCell"
    
    private var image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(image)
        
        image.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView)
            $0.left.right.equalTo(contentView).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepare(image: nil)
    }
    
    func prepare(image: UIImage?) {
        self.image.image = image
    }
}
