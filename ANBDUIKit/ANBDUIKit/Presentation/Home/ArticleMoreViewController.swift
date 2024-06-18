//
//  ArticleMoreView.swift
//  ANBDUIKit
//
//  Created by 최주리 on 6/18/24.
//

import UIKit
import SnapKit

final class ArticleMoreViewController: UIViewController {
    
    private lazy var tabScrollView = UIScrollView()
    private lazy var tabStackView = UIStackView()
    private lazy var accuaTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        tabScrollView = {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
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
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        [tabScrollView].forEach {
            view.addSubview($0)
        }
        
        tabScrollView.addSubview(tabStackView)
        
        [accuaTableView].forEach {
            tabStackView.addArrangedSubview($0)
        }
        
        tabScrollView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(safeArea)
            $0.top.equalTo(safeArea)
        }
        
        tabStackView.snp.makeConstraints {
            $0.edges.equalTo(tabScrollView.contentLayoutGuide)
            $0.width.equalTo(view).multipliedBy(2)
            $0.height.equalTo(tabScrollView.frameLayoutGuide)
        }
    }
}

extension ArticleMoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailView = ArticleDetailViewController()
        self.navigationController?.pushViewController(detailView, animated: true)
    }
    
}

extension ArticleMoreViewController: UITableViewDataSource {
    
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
