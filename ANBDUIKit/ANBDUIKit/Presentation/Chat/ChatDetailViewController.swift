//
//  ChatDetailViewController.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/6/24.
//

import UIKit

final class ChatDetailViewController: UIViewController {
    
    private lazy var headerView = ChatHeader()
    private lazy var scrollView = UIScrollView()
    private lazy var menuButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
        self.title = "김고래"
        
        initAttribute()
        initLayout()
    }
    
    func initAttribute() {
        view.backgroundColor = .systemBackground
        
        menuButton.image = UIImage(systemName: "ellipsis")
        navigationItem.rightBarButtonItem = menuButton
    }
    
    func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        [headerView, scrollView].forEach {
            view.addSubview($0)
        }
        
        headerView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(20)
            $0.top.equalTo(safeArea).inset(10)
            $0.height.equalTo(80)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.horizontalEdges.equalTo(scrollView.contentLayoutGuide).inset(16)
        }
    }
}
