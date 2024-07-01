//
//  EditProfileViewController.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/18/24.
//

import UIKit
import SnapKit

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private let maxNickNameLength = 18
    private var nickNameCountLabel: UILabel!
    private var favLocationLabel: UILabel!
    private var favLocationButton: UIButton!
    private var selectFavLocationTableView: UITableView!
    private var dropDownHeightConstraint: Constraint!
    private let locations = ["서울", "경기", "인천", "광주", "부산", "대구", "대전", "울산", "강원", "경북", "경남", "전북", "전남", "충북", "충남", "세종", "제주"]
    private var isFavLocationDown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "수정하기"
        
        setupView()
        setupConstraints()
        setupselectFavLocationView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        let profileImageView = createImageView(profileImage: "DefaultUserProfileImage.001")
        let selectImageButton = createImageButton()
        
        let nickNameLabel = createLabel(text: "닉네임", weight: .heavy)
        let nickNameTextField = createTextField(placeholder: "짱표")
        
        nickNameTextField.delegate = self
        
        let NickNameDivider = UIView()
        NickNameDivider.backgroundColor = .lightGray
        
        nickNameCountLabel = createLabel(text: "0/\(maxNickNameLength)", weight: .medium)
        nickNameCountLabel.textAlignment = .right
        
        favLocationLabel = createLabel(text: "선호하는 거래 지역", weight: .heavy)
        
        favLocationButton = createFavLocationButton(title: "서울")
        
        view.addSubview(profileImageView)
        view.addSubview(selectImageButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nickNameTextField)
        view.addSubview(NickNameDivider)
        view.addSubview(nickNameCountLabel)
        view.addSubview(favLocationLabel)
        view.addSubview(favLocationButton)
    }
    
    private func setupConstraints() {
        let profileImageView = view.subviews[0]
        let selectImageButton = view.subviews[1]
        let nickNameLabel = view.subviews[2]
        let nickNameTextField = view.subviews[3]
        let nickNameUnderline = view.subviews[4]
        let nickNameCountLabel = view.subviews[5]
        let favLocationLabel = view.subviews[6]
        let favLocationButton = view.subviews[7]
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(95)
        }
        
        selectImageButton.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(-25)
            $0.leading.trailing.equalTo(view).inset(210)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(45)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(15)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(30)
        }
        
        nickNameUnderline.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(1)
        }
        
        nickNameCountLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameUnderline.snp.bottom).offset(5)
            $0.trailing.equalTo(view).inset(20)
            $0.height.equalTo(15)
        }
        
        favLocationLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameCountLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(15)
        }
        
        favLocationButton.snp.makeConstraints {
            $0.top.equalTo(favLocationLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(40)
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
    
    //MARK: - TableView
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
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        nickNameCountLabel.text = "\(newLength)/\(maxNickNameLength)"
        return newLength <= maxNickNameLength
    }
    
    private func createImageView(profileImage: String) -> UIImageView {
        let image = UIImageView()
        
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 47.5
        image.layer.masksToBounds = true
        image.layer.borderWidth = 0.5
        image.image = UIImage(named: profileImage)
        
        return image
    }
    
    private func createImageButton() -> UIButton {
        let button = UIButton(type: .custom)
        let image = UIImageView()
        
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 17.5
        image.layer.masksToBounds = true
        image.image = UIImage(systemName: "camera.circle.fill")
        image.backgroundColor = .black
        image.tintColor = .lightGray
        
        button.addSubview(image)
        
        image.snp.makeConstraints {
            $0.width.height.equalTo(35)
        }
        
        return button
    }
    
    private func createLabel(text: String, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: weight)
        label.textColor = .lightGray
        
        return label
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        textField.textColor = .black
        textField.borderStyle = .none
        
        return textField
    }
    
    private func createFavLocationButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(self, action: #selector(toggleSelectFavLocation), for: .touchUpInside)
        
        return button
    }
}
