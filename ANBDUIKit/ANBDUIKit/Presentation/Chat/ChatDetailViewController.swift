//
//  ChatDetailViewController.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/6/24.
//

import UIKit

final class ChatDetailViewController: UIViewController {
    
    private lazy var buttonConfig = UIButton.Configuration.borderless()
    
    private lazy var contentStackView = UIStackView()
    private lazy var headerView = ChatHeader()
    private lazy var scrollView = UIScrollView()
    private lazy var menuButton = UIBarButtonItem()
    
    private lazy var stackView = UIStackView()
    private lazy var tableView = UITableView()
    
    private lazy var bottomStackView = UIStackView()
    private lazy var pictureButton = UIButton()
    private lazy var messageTextField = UITextField()
    private lazy var sendButton = UIButton()

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
        
        buttonConfig.imagePadding = 5
        buttonConfig.buttonSize = .medium
        
        menuButton.image = UIImage(systemName: "ellipsis")
        navigationItem.rightBarButtonItem = menuButton
        
        contentStackView = {
           let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            return stackView
        }()
        
        scrollView = {
            let scrollView = UIScrollView()
            scrollView.backgroundColor = .systemBackground
            return scrollView
        }()
        
        stackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
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
            tableView.register(MyChattingCell.self, forCellReuseIdentifier: MyChattingCell.identifier)
            tableView.register(YourChattingCell.self, forCellReuseIdentifier: YourChattingCell.identifier)
            return tableView
        }()
        
        pictureButton = {
            let button = UIButton(configuration: buttonConfig)
            button.setImage(UIImage(systemName: "photo.fill"), for: .normal)
            button.tintColor = .lightGray
            return button
        }()
        
        messageTextField = {
            let textField = UITextField()
            textField.placeholder = "메시지 보내기"
            textField.font = .systemFont(ofSize: 15)
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.backgroundColor = .systemGray6
            textField.layer.cornerRadius = 20
            textField.addLeftPadding()
            return textField
        }()
        
        sendButton = {
           let button = UIButton(configuration: buttonConfig)
            button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            
            return button
        }()
        
        bottomStackView = {
           let stackView = UIStackView()
            stackView.distribution = .equalSpacing
            stackView.spacing = 20
            return stackView
        }()
    }
    
    func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(contentStackView)
        
        [headerView, scrollView, bottomStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(tableView)
        
        [pictureButton, messageTextField, sendButton].forEach {
            bottomStackView.addArrangedSubview($0)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalTo(safeArea)
        }
        
        headerView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(20)
            $0.top.equalTo(safeArea).inset(10)
            $0.height.equalTo(80)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.bottom.equalTo(bottomStackView.snp.top)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(view)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalTo(safeArea)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(50)
        }
        
        messageTextField.snp.makeConstraints {
            $0.left.right.equalTo(bottomStackView).inset(40)
            $0.top.bottom.equalTo(bottomStackView).inset(5)
        }
    }
}

extension ChatDetailViewController: UITextFieldDelegate {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("didbeginediting")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChatDetailViewController: UITableViewDelegate {

}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MyChattingCell.identifier,
                for: indexPath
            ) as? MyChattingCell else { return .init() }
            cell.bind()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: YourChattingCell.identifier,
                for: indexPath
            ) as? YourChattingCell else { return .init() }
            cell.bind()
            return cell
        }
    }
}
