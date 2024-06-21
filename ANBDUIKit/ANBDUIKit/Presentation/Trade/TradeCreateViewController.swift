//
//  TradeCreateViewController.swift
//  ANBDUIKit
//
//  Created by 최정인 on 6/20/24.
//

import UIKit

final class TradeCreateViewController: UIViewController {
    
    private let navigationBar = UINavigationBar()
    private lazy var titleTextField = UITextField()
    private lazy var contentTextView = UITextView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        let navigationItem = UINavigationItem(title: "나눠쓰기")
        navigationBar.setItems([navigationItem], animated: true)
        
        navigationItem.leftBarButtonItem = .init(title: "취소", style: .done, target: self, action: #selector(cancelAction))
        
        navigationItem.rightBarButtonItem = .init(title: "완료", style: .done, target: self, action: #selector(cancelAction))
        
        titleTextField = {
            let textField = UITextField()
            textField.placeholder = "제목을 입력하세요"
            textField.delegate = self
            return textField
        }()
        
        contentTextView = {
            let textView = UITextView()
            textView.autocorrectionType = .no
            textView.delegate = self
            return textView
        }()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        [navigationBar, titleTextField, contentTextView].forEach {
            view.addSubview($0)
        }
        
        navigationBar.snp.makeConstraints {
            $0.left.right.top.equalTo(safeArea)
        }
        
        titleTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
        }
        
        contentTextView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(titleTextField.snp.bottom).offset(16)
        }
    }
    
    @objc
    private func cancelAction() {
        self.dismiss(animated: true)
    }
    
    
}


extension TradeCreateViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TradeCreateViewController: UITextViewDelegate {

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.contentOffset.y = max(0, textView.contentSize.height - textView.frame.height)
    }

}
