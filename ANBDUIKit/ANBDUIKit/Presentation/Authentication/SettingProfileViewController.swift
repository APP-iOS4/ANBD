//
//  SettingProfileViewController.swift
//  ANBDUIKit
//
//  Created by 기 표 on 7/16/24.
//

import UIKit
import SnapKit

class SettingProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "2~20자의 닉네임을 입력해 주세요."
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let emailDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let favLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "선호하는 거래 지역"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    private let favLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("서울", for: .normal)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(self, action: #selector(toggleSelectFavLocation), for: .touchUpInside)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private let locations = ["서울", "경기", "인천", "광주", "부산", "대구", "대전", "울산", "강원", "경북", "경남", "전북", "전남", "충북", "충남", "세종", "제주"]
    private var isFavLocationDown = false
    private var selectFavLocationTableView: UITableView!
    private var dropDownHeightConstraint: Constraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupselectFavLocationView()
        
        emailTextField.delegate = self
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(signupLabel)
        view.addSubview(nickNameLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailDivider)
        view.addSubview(favLocationLabel)
        view.addSubview(favLocationButton)
        view.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        signupLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalTo(view).inset(20)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(signupLabel.snp.bottom).offset(50)
            $0.leading.equalTo(view).inset(20)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            $0.leading.equalTo(view).inset(20)
            $0.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
        
        emailDivider.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(1)
        }
        
        favLocationLabel.snp.makeConstraints {
            $0.top.equalTo(emailDivider.snp.bottom).offset(20)
            $0.leading.equalTo(view).inset(20)
        }
        
        favLocationButton.snp.makeConstraints {
            $0.top.equalTo(favLocationLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(40)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(favLocationButton.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(44)
        }
    }
    
    private func setupselectFavLocationView() {
        selectFavLocationTableView = UITableView()
        selectFavLocationTableView.delegate = self
        selectFavLocationTableView.dataSource = self
        selectFavLocationTableView.isHidden = true
        selectFavLocationTableView.layer.cornerRadius = 5
        selectFavLocationTableView.layer.borderWidth = 1
        selectFavLocationTableView.layer.borderColor = UIColor.lightGray.cgColor
        selectFavLocationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        
        view.addSubview(selectFavLocationTableView)
        
        selectFavLocationTableView.snp.makeConstraints {
            $0.top.equalTo(favLocationButton.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(view).inset(20)
            dropDownHeightConstraint = $0.height.equalTo(0).constraint
        }
    }

    @objc private func toggleSelectFavLocation() {
        isFavLocationDown.toggle()
        selectFavLocationTableView.isHidden = !isFavLocationDown
        
        UIView.animate(withDuration: 0.3) {
            self.dropDownHeightConstraint.update(offset: self.isFavLocationDown ? 200 : 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        cell.textLabel?.text = locations[indexPath.row]
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = locations[indexPath.row]
        
        favLocationButton.setTitle(selectedLocation, for: .normal)
        toggleSelectFavLocation()
    }
    
    @objc private func nextButtonTapped() {
        let termsVC = TermsViewController()
        navigationController?.pushViewController(termsVC, animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        updateNextButtonState(with: currentText)
        return true
    }
    
    private func updateNextButtonState(with text: String) {
        let isEnabled = !text.isEmpty
        nextButton.isEnabled = isEnabled
        nextButton.alpha = isEnabled ? 1.0 : 0.5
    }
}
