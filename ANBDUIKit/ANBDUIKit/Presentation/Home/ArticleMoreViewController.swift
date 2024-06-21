//
//  ArticleMoreView.swift
//  ANBDUIKit
//
//  Created by 최주리 on 6/18/24.
//

import UIKit
import SnapKit

final class ArticleMoreViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        scrollView = {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            return scrollView
        }()
        
        contentStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            return stackView
        }()
        
        tableView = {
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
        
        [scrollView].forEach {
            view.addSubview($0)
        }
        
        scrollView.addSubview(contentStackView)
        
        [tableView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        scrollView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(safeArea)
            $0.top.equalTo(safeArea)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(view)
            $0.height.equalTo(scrollView.frameLayoutGuide)
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
        if tableView == tableView {
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
