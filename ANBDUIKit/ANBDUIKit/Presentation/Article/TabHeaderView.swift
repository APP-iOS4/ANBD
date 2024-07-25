//
//  TabHeaderView.swift
//  ANBDUIKit
//
//  Created by 유지호 on 6/3/24.
//

import UIKit

final class TabHeaderView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    let leftTab: UIButton = {
        let button = UIButton()
        button.setTitleColor(.lightGray, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.isSelected = true
        return button
    }()
    
    let rightTab: UIButton = {
        let button = UIButton()
        button.setTitleColor(.lightGray, for: .normal)
        button.setTitleColor(.black, for: .selected)
        return button
    }()
    
    private let indicator: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 1.5
        return view
    }()
    
    private let tab: [Tab]
    
    var selectedTab: Tab {
        didSet {
            if selectedTab == tab[0] {
                leftTab.isSelected = true
                rightTab.isSelected = false
                
                UIView.animate(withDuration: 0.3) {
                    self.indicator.transform = .init(translationX: self.bounds.minX, y: 0)
                }
            } else {
                leftTab.isSelected = false
                rightTab.isSelected = true
                
                UIView.animate(withDuration: 0.3) {
                    self.indicator.transform = .init(translationX: self.bounds.midX + 8, y: 0)
                }
            }
        }
    }
    
    
    init(tab: [Tab]) {
        self.tab = tab
        self.selectedTab = tab[0]
        super.init(frame: .zero)
        
        leftTab.setTitle(tab[0].rawValue, for: .normal)
        rightTab.setTitle(tab[1].rawValue, for: .normal)
        
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initLayout() {
        self.addSubview(stackView)
        self.addSubview(indicator)
        
        stackView.addArrangedSubview(leftTab)
        stackView.addArrangedSubview(rightTab)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints {
            $0.horizontalEdges.equalTo(leftTab)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(3)
        }
    }
    
}
