//
//  TradeViewController.swift
//  ANBDUIKit
//
//  Created by 최정인 on 6/18/24.
//

import UIKit
import SnapKit

final class TradeViewController: UIViewController {
    
    private lazy var headerView = TabHeaderView(tab: [.nanua, .baccua])
    private lazy var tabScrollView = UIScrollView()
    private lazy var tabStackView = UIStackView()
    private lazy var nanuaTableView = UITableView()
    private lazy var baccuaTableView = UITableView()
    
    private lazy var writeButton = UIButton()
    
    private var selectedTab: Tab = .nanua {
        didSet {
            headerView.selectedTab = selectedTab
            
            if selectedTab == .nanua {
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
        title = "나눔 · 거래"
        view.backgroundColor = .systemBackground
        
        headerView.leftTab.addTarget(nil, action: #selector(tapNanuaTab), for: .touchUpInside)
        headerView.rightTab.addTarget(nil, action: #selector(tapBaccuaTab), for: .touchUpInside)
        
        tabScrollView = {
            let scrollView = UIScrollView()
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
        
        nanuaTableView = {
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(TradeCell.self, forCellReuseIdentifier: TradeCell.identifier)
            return tableView
        }()
        
        baccuaTableView = {
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(TradeCell.self, forCellReuseIdentifier: TradeCell.identifier)
            return tableView
        }()
        
        writeButton = {
            let button = UIButton(configuration: .borderedProminent())
            button.setTitle("글쓰기", for: .normal)
            button.setImage(.init(systemName: "plus"), for: .normal)
            button.layer.cornerRadius = 25
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(tapWriteButton), for: .touchUpInside)
            return button
        }()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        [headerView, tabScrollView, writeButton].forEach {
            view.addSubview($0)
        }
        
        tabScrollView.addSubview(tabStackView)
        
        [nanuaTableView, baccuaTableView].forEach {
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
    private func tapNanuaTab() {
        selectedTab = .nanua
    }
    
    @objc
    private func tapBaccuaTab() {
        selectedTab = .baccua
    }
    
    @objc
    private func tapWriteButton() {
        let vc = TradeCreateViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension TradeViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == tabScrollView else { return }
        
        if targetContentOffset.pointee.x < view.frame.width {
            selectedTab = .nanua
        } else {
            selectedTab = .baccua
        }
    }
}

extension TradeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailView = TradeDetailViewController()
        self.navigationController?.pushViewController(detailView, animated: true)
    }
}

extension TradeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == nanuaTableView {
            return 5
        } else {
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TradeCell.identifier, for: indexPath) as? TradeCell else { return .init() }
        cell.bind()
        return cell
    }
}
