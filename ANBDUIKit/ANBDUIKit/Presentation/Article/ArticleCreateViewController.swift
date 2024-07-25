//
//  ArticleCreateViewController.swift
//  ANBDUIKit
//
//  Created by 유지호 on 6/4/24.
//

import UIKit
import PhotosUI

final class ArticleCreateViewController: UIViewController {
    
    private let navigationBar = UINavigationBar()
    private lazy var noticeLabel = RoundedLabel()
    private lazy var titleTextField = UITextField()
    private lazy var contentTextView = UITextView()
    
    private let photoView = UIView()
    private lazy var photoButton = UIButton()
    private lazy var photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private lazy var picker = PHPickerViewController(configuration: .init())
    
    private var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    
    private func initAttribute() {
        view.backgroundColor = .systemBackground
        
        let navigationItem = UINavigationItem(title: "오잉")
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.standardAppearance = appearance
        
        navigationItem.leftBarButtonItem = .init(
            title: "취소",
            style: .done,
            target: self,
            action: #selector(cancelAction)
        )
        
        navigationItem.rightBarButtonItem = .init(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(doneAction)
        )
        
        noticeLabel = {
            let label = RoundedLabel(
                padding: .init(top: 16, left: 14, bottom: 16, right: 14),
                cornerRadius: 10
            )
            label.text = "명예훼손, 광고/홍보 목적의 글은 올리실 수 없어요."
            label.textColor = .white
            label.backgroundColor = .blue
            return label
        }()
        
        titleTextField = {
            let textField = UITextField()
            textField.placeholder = "제목을 입력하세요"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.delegate = self
            return textField
        }()
        
        contentTextView = {
            let textView = UITextView()
            textView.autocorrectionType = .no
            textView.autocapitalizationType = .none
            textView.delegate = self
            return textView
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
        
        photoButton = {
            let button = UIButton(frame: .init(x: 0, y: 0, width: 20, height: 20))
            button.setTitle("사진", for: .normal)
            button.setTitleColor(.tintColor, for: .normal)
            button.setImage(.init(systemName: "photo"), for: .normal)
            button.tintColor = .tintColor
            button.addTarget(self, action: #selector(photoButtonAction), for: .touchUpInside)
            return button
        }()
        
        photoCollectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = .init(width: 50, height: 50)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
            collectionView.dataSource = self
            collectionView.delegate = self
            return collectionView
        }()
    }
    
    private func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let keyboardLayout = view.keyboardLayoutGuide
        
        [navigationBar, noticeLabel, titleTextField, contentTextView, photoCollectionView, photoView].forEach {
            view.addSubview($0)
        }
        
        photoView.addSubview(photoButton)
        
        navigationBar.snp.makeConstraints {
            $0.left.right.top.equalTo(safeArea)
        }
        
        noticeLabel.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(navigationBar.snp.bottom)
        }
        
        titleTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(noticeLabel.snp.bottom).offset(24)
        }
        
        contentTextView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(titleTextField.snp.bottom).offset(16)
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.top.equalTo(contentTextView.snp.bottom)
            $0.height.equalTo(60)
        }
        
        photoView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeArea)
            $0.top.equalTo(photoCollectionView.snp.bottom)
            $0.bottom.equalTo(keyboardLayout.snp.top)
            $0.height.equalTo(56)
        }
        
        photoButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc
    private func photoButtonAction() {
        self.present(picker, animated: true)
    }
    
    @objc
    private func cancelAction() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func doneAction() {
        self.dismiss(animated: true)
    }
    
}


extension ArticleCreateViewController: UICollectionViewDataSource {
    
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

extension ArticleCreateViewController: UICollectionViewDelegateFlowLayout {
    
}

extension ArticleCreateViewController: PHPickerViewControllerDelegate {
    
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

extension ArticleCreateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension ArticleCreateViewController: UITextViewDelegate {

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.contentOffset.y = max(0, textView.contentSize.height - textView.frame.height)
    }

}
