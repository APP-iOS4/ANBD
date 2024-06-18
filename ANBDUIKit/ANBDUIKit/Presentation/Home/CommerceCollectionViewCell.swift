//
//  CommerceCollectionViewCell.swift
//  ANBDUIKit
//
//  Created by 최주리 on 6/14/24.
//

import UIKit
import SnapKit

final class CommerceCollectionViewCell: UICollectionViewCell {
    static let id = "CommerceCell"
    
    private var image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        image.snp.makeConstraints {
            $0.edges.equalTo(contentView)
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
