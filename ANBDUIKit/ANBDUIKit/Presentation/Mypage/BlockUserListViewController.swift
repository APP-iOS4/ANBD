//
//  BlockUserListViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/24/24.
//

import UIKit
import SnapKit

class BlockUserListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        
        let emptyImage: UIImageView = {
            let image = UIImageView()
            image.image = UIImage(systemName: "tray")
            image.contentMode = .scaleAspectFit
            image.tintColor = .darkGray
            return image
        }()
        
        let emptyLabel: UILabel = {
            let label = UILabel()
            label.text = "차단한 사용자가 없습니다."
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.textColor = .gray
            label.textAlignment = .center
            return label
        }()
        
        view.addSubview(emptyImage)
        view.addSubview(emptyLabel)
        
    }
    private func setupConstraints() {
        let emptyImage = view.subviews[0]
        let emptyLabel = view.subviews[1]
        
        emptyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
            $0.width.height.equalTo(65)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImage.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
    }
}
