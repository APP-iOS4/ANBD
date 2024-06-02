//
//  Home.swift
//  ANBDUIKit
//
//  Created by 최정인 on 5/31/24.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    // 스크롤 뷰
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .brown
        
        return scrollView
    }()
    
    // 광고 뷰
    let commerceView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        
        return view
    }()
    
    //아껴쓰기 스택
    let accuaStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.backgroundColor = .red
        
        return stackView
    }()
    
    let accuaTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "아껴쓰기"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .left
        
        return label
    }()
    
    // search button
    lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped(_:)))
        //button.image = UIImage(systemName: "magnifyingglass")
        button.tag = 1
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .green
        self.title = "ANBD"
        self.navigationItem.rightBarButtonItem = self.searchButton
        
        addView()
        buildAutoLayout()
    }
    
    func addView() {
        view.addSubview(scrollView)
        
//        scrollView.addSubview(commerceView)
        scrollView.addSubview(accuaStackView)
        
        accuaStackView.addSubview(accuaTitleLabel)
    }
    
    func buildAutoLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
//        commerceView.snp.makeConstraints { make in
//            make.edges.equalTo(self.scrollView)
//        }
        
        accuaStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
        }
    }
    
    
    @objc func searchButtonTapped(_ sender: Any) {
        //        let searchViewController = SearchViewController()
        //        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
}
