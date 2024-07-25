//
//  TradeCreateViewController.swift
//  ANBDUIKit
//
//  Created by 최정인 on 6/20/24.
//

import UIKit
import SnapKit
import PhotosUI

class TradeCreateViewController: UIViewController {
    
    private let categories = ["디지털기기", "가구/인테리어", "남성 의류/잡화", "여성 의류/잡화", "뷰티/미용", "생활가전", "스포츠/레저", "생활/주방", "취미/게임/음반/도서", "반려동물 용품", "기타 중고물품"]
    private let locations = ["서울", "경기", "인천", "광주", "부산", "대구", "대전", "울산", "강원", "경북", "경남", "전북", "전남", "충북", "충남", "세종", "제주"]
    
    // MARK: - 변수 선언
    private let navigationBar = UINavigationBar()
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    
    private lazy var photoStackView = UIStackView()
    private lazy var photoButton = UIButton()
    private lazy var photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private lazy var picker = PHPickerViewController(configuration: .init())
    private var selectedImages: [UIImage] = []
    
    private lazy var titleLabel = UILabel()
    private lazy var titleTextField = UITextField()
    
    private lazy var tradeTypeStackView = UIStackView()
    private lazy var typeLabel = UILabel()
    private lazy var typeButtonStackView = UIStackView()
    private lazy var baccuaStackView = UIStackView()
    private lazy var nanuaButton = UIButton()
    private lazy var baccuaButton = UIButton()
    private lazy var nanuaTextField = UITextField()
    private lazy var baccuaTextField = UITextField()
    private lazy var productMiddleImageView = UIImageView()
    private lazy var wantedProductTextField = UITextField()
    
    private lazy var categoryLabel = UILabel()
    private lazy var categoryButton = UIButton()
    private lazy var categoryTableView = UITableView()
    private var categoryHeightConstraint: Constraint!
    private var isCategorySelecting = false
    
    private lazy var locationLabel = UILabel()
    private lazy var locationButton = UIButton()
    private lazy var locationTableView = UITableView()
    private var locationHeightConstraint: Constraint!
    private var isLocationSelecting = false
    
    private lazy var descriptionLabel = UILabel()
    private lazy var descriptionView = UIView()
    private lazy var descriptionPlaceholder = UILabel()
    private lazy var descriptionTextView = UITextView()
    
    private lazy var completeButton = UIButton()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    // MARK: - 뷰 구성
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        /// 네비게이션 바
        let navigationItem = UINavigationItem(title: "새 상품 등록")
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.standardAppearance = appearance
        
        navigationItem.leftBarButtonItem = .init(title: "취소", style: .done, target: self, action: #selector(cancelAction))
        
        // 스크롤뷰
        scrollView = {
            let scrollView = UIScrollView()
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.canCancelContentTouches = true
            return scrollView
        }()
        contentStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 20
            return stackView
        }()
        
        // 사진 선택
        photoStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 5
            return stackView
        }()
        
        photoButton = {
            let button = UIButton()
            button.backgroundColor = .clear
            let image = UIImage(systemName: "camera.fill")?.resized(to: CGSize(width: 40, height: 23))
            button.setImage(image, for: .normal)
            button.contentVerticalAlignment = .center
            button.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(selectPhotos), for: .touchUpInside)
            return button
        }()
        picker = {
            var pickerConfig = PHPickerConfiguration()
            pickerConfig.selection = .ordered
            pickerConfig.selectionLimit = 5
            pickerConfig.filter = .images
            let pickerVC = PHPickerViewController(configuration: pickerConfig)
            pickerVC.delegate = self
            return pickerVC
        }()
        
        photoCollectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = .init(width: 60, height: 60)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
            collectionView.dataSource = self
            collectionView.delegate = self
            return collectionView
        }()
        
        // 상품 등록 (제목)
        titleLabel = createLable("제목")
        titleTextField = {
            let textField = UITextField()
            textField.backgroundColor = .clear
            textField.layer.cornerRadius = 8
            textField.clipsToBounds = true
            textField.layer.borderWidth = 1
            textField.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            textField.placeholder = "제목"
            textField.leftPadding()
            textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
            return textField
        }()
        
        // 상품 등록 (거래 방식)
        typeLabel = createLable("거래 방식")
        tradeTypeStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            return stackView
        }()
        
        typeButtonStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            return stackView
        }()
        
        nanuaButton = {
            let button = UIButton()
            button.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
            button.layer.cornerRadius = 15
            button.clipsToBounds = true
            button.setTitle("    나눠쓰기    ", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15)
            button.addTarget(self, action: #selector(tapNanuaButton), for: .touchUpInside)
            return button
        }()
        
        baccuaButton = {
            let button = UIButton()
            button.backgroundColor = .clear
            button.layer.cornerRadius = 15
            button.clipsToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            button.setTitle("    바꿔쓰기    ", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15)
            button.addTarget(self, action: #selector(tapBaccuaButton), for: .touchUpInside)
            return button
        }()
        
        nanuaTextField = {
            let textField = UITextField()
            textField.backgroundColor = .clear
            textField.layer.cornerRadius = 8
            textField.clipsToBounds = true
            textField.layer.borderWidth = 1
            textField.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            textField.placeholder = "나눌 물건"
            textField.leftPadding()
            textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
            return textField
        }()
        
        baccuaTextField = {
            let textField = UITextField()
            textField.backgroundColor = .clear
            textField.layer.cornerRadius = 8
            textField.clipsToBounds = true
            textField.layer.borderWidth = 1
            textField.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            textField.placeholder = "바꿀 물건"
            textField.leftPadding()
            textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
            return textField
        }()
        
        productMiddleImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "arrow.left.and.right")?.resized(to: CGSize(width: 20, height: 5))
            imageView.tintColor = .darkGray
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        wantedProductTextField = {
            let textField = UITextField()
            textField.backgroundColor = .clear
            textField.layer.cornerRadius = 8
            textField.clipsToBounds = true
            textField.layer.borderWidth = 1
            textField.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            textField.placeholder = "받고 싶은 물건"
            textField.leftPadding()
            textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
            return textField
        }()
        
        baccuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 5
            stackView.alignment = .fill
            stackView.distribution = .fillProportionally
            return stackView
        }()
        
        // 상품등록 (카테고리)
        categoryLabel = createLable("카테고리")
        categoryButton = createTableButton("카테고리")
        categoryTableView = {
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
            tableView.layer.cornerRadius = 5
            tableView.layer.borderWidth = 1
            tableView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
            return tableView
        }()
        
        // 상품등록 (지역)
        locationLabel = createLable("지역")
        locationButton = createTableButton("지역", isCategory: false)
        locationTableView = {
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
            tableView.layer.cornerRadius = 5
            tableView.layer.borderWidth = 1
            tableView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
            return tableView
        }()
        
        // 상품등록 (상세설명)
        descriptionLabel = createLable("상세설명")
        descriptionView = {
            let view = UIView()
            view.layer.borderWidth = 1
            view.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
            return view
        }()
        descriptionPlaceholder = {
            let label = UILabel()
            label.text = "나누고자 하는 물건에 대한 설명을 작성해주세요.\n(거래 금지 물품은 게시가 제한될 수 있어요.)"
            label.numberOfLines = 2
            label.textColor = .lightGray
            return label
        }()
        descriptionTextView = {
            let textView = UITextView()
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 10)
            textView.autocorrectionType = .no
            textView.autocapitalizationType = .none
            textView.font = .systemFont(ofSize: 15)
            textView.textColor = .black
            textView.delegate = self
            return textView
        }()
        
        // 작성완료 버튼
        completeButton = {
            let button = UIButton(type: .custom)
            button.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.setTitle("작성 완료", for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.isEnabled = false
            button.addTarget(self, action: #selector(completeButtonAction), for: .touchUpInside)
            return button
        }()
    }
    
    // MARK: - 레이아웃
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        // Add Subview
        [navigationBar, scrollView, completeButton].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentStackView)
        
        [photoStackView, titleLabel, titleTextField, tradeTypeStackView, categoryLabel, categoryButton, categoryTableView, locationLabel, locationButton, locationTableView, descriptionLabel, descriptionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        [photoButton, photoCollectionView].forEach {
            photoStackView.addArrangedSubview($0)
        }
        
        [typeLabel, typeButtonStackView, nanuaTextField, baccuaStackView].forEach {
            tradeTypeStackView.addArrangedSubview($0)
        }
        baccuaStackView.isHidden = true
        
        [nanuaButton, baccuaButton, UIView()].forEach {
            typeButtonStackView.addArrangedSubview($0)
        }
        
        [baccuaTextField, productMiddleImageView, wantedProductTextField].forEach {
            baccuaStackView.addArrangedSubview($0)
        }
        
        [descriptionTextView, descriptionPlaceholder].forEach {
            descriptionView.addSubview($0)
        }
        
        
        // 레이아웃 잡기
        navigationBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(safeArea)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalTo(safeArea)
            $0.bottom.equalTo(safeArea).inset(60)
        }
        
        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.verticalEdges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide).offset(-32)
        }
        
        photoStackView.snp.makeConstraints {
            $0.top.equalTo(contentStackView)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(70)
        }
        
        photoButton.snp.makeConstraints {
            $0.height.width.equalTo(60)
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.height.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(photoButton.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(40)
        }
        
        tradeTypeStackView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
        }
        
        typeLabel.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
        }
        
        typeButtonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(30)
        }
        
        nanuaTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(40)
        }
        
        baccuaStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(40)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(tradeTypeStackView.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
        }
        
        categoryButton.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(40)
        }
        
        categoryTableView.snp.makeConstraints {
            $0.top.equalTo(categoryButton.snp.bottom).offset(5)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            categoryHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(categoryTableView.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
        }
        
        locationButton.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(40)
        }
        
        locationTableView.snp.makeConstraints {
            $0.top.equalTo(locationButton.snp.bottom).offset(5)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            locationHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(locationTableView.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
        }
        
        descriptionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(170)
        }
        
        descriptionPlaceholder.snp.makeConstraints {
            $0.top.equalTo(descriptionView).offset(10)
            $0.horizontalEdges.equalTo(descriptionView).inset(10)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionView)
            $0.horizontalEdges.equalTo(descriptionView)
            $0.height.equalTo(150)
        }
        
        completeButton.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.bottom.equalTo(safeArea)
            $0.height.equalTo(50)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.scrollView.endEditing(true)
    }
}

// MARK: - init 외의 함수들 정의
extension TradeCreateViewController {
    @objc
    private func cancelAction() {
        dismiss(animated: true)
    }
    
    @objc
    private func selectPhotos() {
        self.present(picker, animated: true)
    }
    
    @objc
    private func tapNanuaButton() {
        if baccuaButton.backgroundColor == #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1) {
            baccuaButton.backgroundColor = .clear
            baccuaButton.layer.borderWidth = 1
            baccuaButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            baccuaButton.setTitleColor(.black, for: .normal)
        }
        nanuaButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
        nanuaButton.layer.borderWidth = 0
        nanuaButton.setTitleColor(.white, for: .normal)
        
        if descriptionTextView.text == "" {
            descriptionPlaceholder.text = "나누고자 하는 물건에 대한 설명을 작성해주세요.\n(거래 금지 물품은 게시가 제한될 수 있어요.)"
        }
        
        baccuaTextField.text = ""
        wantedProductTextField.text = ""
        completeButton.isEnabled = false
        completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        nanuaTextField.isHidden = false
        baccuaStackView.isHidden = true
    }
    
    @objc
    private func tapBaccuaButton() {
        if nanuaButton.backgroundColor == #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)  {
            nanuaButton.backgroundColor = .clear
            nanuaButton.layer.borderWidth = 1
            nanuaButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            nanuaButton.setTitleColor(.black, for: .normal)
        }
        baccuaButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
        baccuaButton.layer.borderWidth = 0
        baccuaButton.setTitleColor(.white, for: .normal)
        
        if descriptionTextView.text == "" {
            descriptionPlaceholder.text = "내 물건에 대한 설명, 원하는 물건에 대한 설명 등 바꿀 물건에 대한 내용을 작성해주세요.\n\n받고 싶은 물건의 후보가 여러가지라면 여기에 작성해주세요.\n(거래 금지 물품은 게시가 제한될 수 있어요.)"
            descriptionPlaceholder.numberOfLines = 6
        }
        
        nanuaTextField.text = ""
        completeButton.isEnabled = false
        completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        nanuaTextField.isHidden = true
        baccuaStackView.isHidden = false
    }
    
    @objc
    private func toggleSelectCategory() {
        isCategorySelecting.toggle()
        categoryTableView.isHidden = !isCategorySelecting
        
        UIView.animate(withDuration: 0.3) {
            self.categoryHeightConstraint.update(offset: self.isCategorySelecting ? 480 : 0)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func toggleSelectLocation() {
        isLocationSelecting.toggle()
        locationTableView.isHidden = !isLocationSelecting
        
        UIView.animate(withDuration: 0.3) {
            self.locationHeightConstraint.update(offset: self.isLocationSelecting ? 705 : 0)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func completeButtonAction() {
        dismiss(animated: true)
    }
    
    @objc
    func textFieldEditingChanged() {
        if titleTextField.text != "" && categoryButton.titleLabel?.text != "카테고리" && locationButton.titleLabel?.text != "지역" && descriptionTextView.text != "" && !selectedImages.isEmpty {
            if baccuaStackView.isHidden {
                if nanuaTextField.text != "" {
                    completeButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
                    completeButton.setTitleColor(.white, for: .normal)
                    completeButton.isEnabled = true
                } else {
                    completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                    completeButton.isEnabled = false
                }
            } else {
                if baccuaTextField.text != "" && wantedProductTextField.text != "" {
                    completeButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
                    completeButton.setTitleColor(.white, for: .normal)
                    completeButton.isEnabled = true
                } else {
                    completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                    completeButton.isEnabled = false
                }
            }
        } else {
            completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            completeButton.isEnabled = false
        }
    }
    
    private func createLable(_ string: String) -> UILabel {
        let label = UILabel()
        label.text = string
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }
    
    private func createTableButton(_ string: String, isCategory: Bool = true) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(string, for: .normal)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        if isCategory {
            button.addTarget(self, action: #selector(toggleSelectCategory), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(toggleSelectLocation), for: .touchUpInside)
        }
        return button
    }
}

// MARK: - 테이블뷰 관련 Extension
extension TradeCreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == categoryTableView {
            return categories.count
        } else {
            return locations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
            cell.textLabel?.text = categories[indexPath.row]
            cell.textLabel?.textAlignment = .center
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            cell.textLabel?.text = locations[indexPath.row]
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoryTableView {
            let selectedCategory = categories[indexPath.row]
            categoryButton.setTitle(selectedCategory, for: .normal)
            toggleSelectCategory()
        } else {
            let selectedLocation = locations[indexPath.row]
            locationButton.setTitle(selectedLocation, for: .normal)
            toggleSelectLocation()
        }
    }
}

// MARK: - TextView 관련 extension
extension TradeCreateViewController: UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // textView에 focus를 잃는 경우
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionPlaceholder.isHidden = false
        }
    }
    
    // textView 텍스트 입력 ..
    func textViewDidChange(_ textView: UITextView) {
        if textView.text?.count == 1 {
            if textView.text?.first == " " {
                textView.text = ""
                return
            }
        } else if textView.text.isEmpty {
            descriptionPlaceholder.isHidden = false
        } else {
            descriptionPlaceholder.isHidden = true
        }
        
        if titleTextField.text != "" && categoryButton.titleLabel?.text != "카테고리" && locationButton.titleLabel?.text != "지역" && descriptionTextView.text != "" && !selectedImages.isEmpty {
            if baccuaStackView.isHidden {
                if nanuaTextField.text != "" {
                    completeButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
                    completeButton.setTitleColor(.white, for: .normal)
                    completeButton.isEnabled = true
                } else {
                    completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                    completeButton.isEnabled = false
                }
            } else {
                if baccuaTextField.text != "" && wantedProductTextField.text != "" {
                    completeButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6392156863, blue: 1, alpha: 1)
                    completeButton.setTitleColor(.white, for: .normal)
                    completeButton.isEnabled = true
                } else {
                    completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                    completeButton.isEnabled = false
                }
            }
        } else {
            completeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            completeButton.isEnabled = false
        }
    }
    
}

extension TradeCreateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier,
            for: indexPath
        ) as? PhotoCell
        else { return .init() }
        cell.bind(image: selectedImages[indexPath.row])
        return cell
    }
}

extension TradeCreateViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var images: [UIImage] = []
        
        results.forEach { result in
            let itemProvider = result.itemProvider
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
            
            itemProvider.loadObject(ofClass: UIImage.self) {image, error in
                if let image = image as? UIImage {
                    images.append(image)
                }
                
                if let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.selectedImages = images
            
            DispatchQueue.main.async {
                self?.photoCollectionView.reloadData()
            }
        }
    }
}



// MARK: - UITextField 관련 extension
extension UITextField {
    func leftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
