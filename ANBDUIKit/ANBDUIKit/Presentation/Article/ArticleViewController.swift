//
//  ArticleViewController.swift
//  ANBDUIKit
//
//  Created by 최정인 on 5/31/24.
//

import UIKit
import SnapKit

enum Tab: String, CaseIterable {
    case accua = "아껴쓰기"
    case nanua = "나눠쓰기"
    case baccua = "바꿔쓰기"
    case dasi = "다시쓰기"
}

final class ArticleViewController: UIViewController {
    
    private lazy var searchButton = UIBarButtonItem()
    private lazy var headerView = TabHeaderView(tab: [.accua, .dasi])
    private lazy var tabScrollView = UIScrollView()
    private lazy var tabStackView = UIStackView()
    private lazy var accuaTableView = UITableView()
    private lazy var dasiTableView = UITableView()
    private lazy var writeButton = UIButton()
    
    private var selectedTab: Tab = .accua {
        didSet {
            headerView.selectedTab = selectedTab
            
            if selectedTab == .accua {
                tabScrollView.setContentOffset(.init(x: 0, y: 0), animated: true)
            } else {
                tabScrollView.setContentOffset(.init(x: view.frame.width, y: 0), animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    
    private func initAttribute() {
        title = "정보 공유"
        view.backgroundColor = .systemBackground
        
        searchButton.image = UIImage(systemName: "magnifyingglass")
        navigationItem.rightBarButtonItem = searchButton
        
        headerView.leftTab.addTarget(nil, action: #selector(leftTabAction), for: .touchUpInside)
        headerView.rightTab.addTarget(nil, action: #selector(rightTabAction), for: .touchUpInside)
        
        tabScrollView = {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delegate = self
            return scrollView
        }()
        
        tabStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            return stackView
        }()
        
        accuaTableView = {
            let tableView = UITableView()
            tableView.separatorStyle = .none
            tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
            tableView.showsVerticalScrollIndicator = true
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
            return tableView
        }()
        
        dasiTableView = {
            let tableView = UITableView()
            tableView.separatorStyle = .none
            tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
            tableView.showsVerticalScrollIndicator = true
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
            return tableView
        }()
        
        writeButton = {
            let button = UIButton(configuration: .borderedProminent())
            button.setTitle("글쓰기", for: .normal)
            button.setImage(.init(systemName: "plus"), for: .normal)
            button.layer.cornerRadius = 25
            button.clipsToBounds = true
            return button
        }()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        [headerView, tabScrollView, writeButton].forEach {
            view.addSubview($0)
        }
        
        tabScrollView.addSubview(tabStackView)
        
        [accuaTableView, dasiTableView].forEach {
            tabStackView.addArrangedSubview($0)
        }
        
        headerView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(safeArea)
            $0.height.equalTo(56)
        }
        
        tabScrollView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(safeArea)
            $0.top.equalTo(headerView.snp.bottom)
        }
        
        tabStackView.snp.makeConstraints {
            $0.edges.equalTo(tabScrollView.contentLayoutGuide)
            $0.width.equalTo(view).multipliedBy(2)
            $0.height.equalTo(tabScrollView.frameLayoutGuide)
        }
        
        writeButton.snp.makeConstraints {
            $0.right.bottom.equalTo(safeArea).inset(14)
            $0.height.equalTo(52)
        }
    }
    
    @objc
    private func leftTabAction() {
        selectedTab = .accua
    }
    
    @objc
    private func rightTabAction() {
        selectedTab = .dasi
    }
    
}


extension ArticleViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard scrollView == tabScrollView else { return }
        
        if targetContentOffset.pointee.x < view.frame.width {
            selectedTab = .accua
        } else {
            selectedTab = .dasi
        }
    }
    
}

extension ArticleViewController: UITableViewDelegate { }

extension ArticleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == accuaTableView {
            return 10
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleCell.identifier,
            for: indexPath
        ) as? ArticleCell else { return .init() }
        cell.bind()
        return cell
    }
    
    
}
