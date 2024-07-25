//
//  Chat.swift
//  ANBDUIKit
//
//  Created by 최정인 on 5/31/24.
//

import UIKit

final class ChatViewController: UIViewController {
    private lazy var scrollView = UIScrollView()
    private lazy var stackView = UIStackView()
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    private func initAttribute() {
        title = "채팅"
        view.backgroundColor = .systemBackground
        
        scrollView = {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delegate = self
            return scrollView
        }()
        
        stackView = {
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
            tableView.register(ChatListCell.self, forCellReuseIdentifier: ChatListCell.identifier)
            return tableView
        }()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(tableView)

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeArea).inset(10)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(view)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailView = ChatDetailViewController()
        detailView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailView, animated: true)
    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatListCell.identifier,
            for: indexPath
        ) as? ChatListCell else { return .init() }
        cell.bind()
        return cell
    }
    
    
}

