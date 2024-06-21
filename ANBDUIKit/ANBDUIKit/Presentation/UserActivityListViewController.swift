//
//  UserActivityListViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/2/24.
//

import UIKit
import SnapKit

class UserActivityListViewController: UIViewController {
    // tab
    private let tabView = TabView()
    
    // page
    private lazy var pagerView: PagerView = {
        return PagerView(items: self.items, title: self.emptyText)
    }()
    
    private let items: [String]
    private let emptyText: String
        
    init(items: [String], emptyText: String) {
        self.items = items
        self.emptyText = emptyText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabView.dataSource = items
        setupLayout()
        handleScroll()
        
        DispatchQueue.main.async {
            self.tabView.syncUnderlineView(index: 0, underlineView: self.tabView.highlightView)
        }
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        view.addSubview(tabView)
        view.addSubview(pagerView)
        
        tabView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        pagerView.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // 탭, 페이지 스크롤 이벤트 처리
    private func handleScroll() {
        // 탭 했을 때 호출됨
        // 페이지와 탭이 해당 인덱스로 스크롤하고, 하이라이트 뷰를 동기화함
        tabView.didTap = { [weak self] index in
            guard let self = self else { return }
            pagerView.scroll(to: index)
            tabView.syncUnderlineView(index: index, underlineView: tabView.highlightView)
        }
        
        // 스크롤이 끝났을 때 호출됨
        // 해당 페이지 인덱스로 하이라이트 뷰를 동기화함
        pagerView.didEndScroll = { [weak self] index in
            guard let self = self else { return }
            tabView.syncUnderlineView(index: index, underlineView: tabView.highlightView)
        }
    }
}
