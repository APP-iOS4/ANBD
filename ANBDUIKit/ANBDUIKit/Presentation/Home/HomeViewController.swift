//
//  Home.swift
//  ANBDUIKit
//
//  Created by 최정인 on 5/31/24.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    private lazy var searchButton = UIBarButtonItem()
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    
    private lazy var commerceImageView = UIImageView()
    private lazy var accuaStackView = UIStackView()
    private lazy var nanuaStackView = UIStackView()
    private lazy var baccuaStackView = UIStackView()
    private lazy var dasiStackView = UIStackView()
    
    private lazy var accuaTitleLabel = UILabel()
    private lazy var accuaDescriptionLabel = UILabel()
    private lazy var accuaImageView = UIImageView()
    private var accuaDividerView = UIView()
    private var accuaMoreButton = UIButton()
    
    private lazy var nanuaTitleLabel = UILabel()
    private lazy var nanuaDescriptionLabel = UILabel()
    private var nanuaDividerView = UIView()
    private lazy var nanuaImageStackView = UIStackView()
    private lazy var nanuaImageView = UIImageView()
    private lazy var nanuaScrollView = UIScrollView()
    
    private lazy var baccuaTitleLabel = UILabel()
    private lazy var baccuaDescriptionLabel = UILabel()
    private var baccuaDividerView = UIView()
    
    private lazy var dasiTitleLabel = UILabel()
    private lazy var dasiDescriptionLabel = UILabel()
    private lazy var dasiImageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        initAttribute()
        addView()
        initLayout()
    }
    
    func initAttribute() {
        searchButton.image = UIImage(systemName: "magnifyingglass")
        navigationItem.rightBarButtonItem = searchButton
        
        scrollView = {
            let scrollView = UIScrollView()
            return scrollView
        }()
        contentStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
//            stackView.distribution = .equalCentering
            stackView.spacing = 100
            
            return stackView
        }()
        
        accuaDividerView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            
            return view
        }()
        nanuaDividerView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            
            return view
        }()
        baccuaDividerView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            
            return view
        }()
        
        commerceImageView = {
            let imageView = UIImageView()
            let image = UIImage(named: "sampleImage")
            let resizedImage = image?.resized(to: CGSize(width: view.frame.width, height: 150))
            imageView.layer.cornerRadius = 15
            imageView.image = resizedImage
            imageView.contentMode = .scaleAspectFill
            
            imageView.clipsToBounds = true
            return imageView
        }()
        
        accuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        nanuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        baccuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        dasiStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        
        accuaTitleLabel = {
            let label = UILabel()
            label.text = "아껴쓰기"
            label.font = UIFont.preferredFont(forTextStyle: .title2)
            
            return label
        }()
        accuaDescriptionLabel = {
            let label = UILabel()
            label.text = "어쩌구 저쩌구 아껴쓰세용~~"
            
            return label
        }()
        accuaImageView = {
            let imageView = UIImageView()
            let image = UIImage(named: "sampleImage")
            let resizedImage = image?.resized(to: CGSize(width: view.frame.width, height: 150))
            imageView.layer.cornerRadius = 15
            imageView.image = resizedImage
            imageView.contentMode = .scaleAspectFill
            
            imageView.clipsToBounds = true
            return imageView
        }()
        accuaMoreButton = {
            let button = UIButton()
            button.setTitle("더보기", for: .normal)
            button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            return button
        }()
        
        nanuaTitleLabel = {
            let label = UILabel()
            label.text = "나눠쓰기"
            label.font = UIFont.preferredFont(forTextStyle: .title2)
            
            return label
        }()
        nanuaDescriptionLabel = {
            let label = UILabel()
            label.text = "어쩌구 저쩌구 나눠쓰세용~~"
            
            return label
        }()
        nanuaImageView = {
            let imageView = UIImageView()
            let image = UIImage(named: "sampleImage")
            let resizedImage = image?.resized(to: CGSize(width: 35, height: 35))
            imageView.layer.cornerRadius = 10
            imageView.image = resizedImage
            imageView.contentMode = .scaleAspectFit
            
            imageView.clipsToBounds = true
            return imageView
        }()
        nanuaImageStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            
            return stackView
        }()
        
        baccuaTitleLabel = {
            let label = UILabel()
            label.text = "바꿔쓰기"
            label.font = UIFont.preferredFont(forTextStyle: .title2)
            
            return label
        }()
        baccuaDescriptionLabel = {
            let label = UILabel()
            label.text = "어쩌구 저쩌구 바꿔쓰세용~~"
            
            return label
        }()
        
        dasiTitleLabel = {
            let label = UILabel()
            label.text = "다시쓰기"
            label.font = UIFont.preferredFont(forTextStyle: .title2)
            
            return label
        }()
        dasiDescriptionLabel = {
            let label = UILabel()
            label.text = "어쩌구 저쩌구 다시쓰세용~~"
            
            return label
        }()
        dasiImageView = {
            let imageView = UIImageView()
            let image = UIImage(named: "sampleImage")
            let resizedImage = image?.resized(to: CGSize(width: view.frame.width, height: 150))
            imageView.layer.cornerRadius = 15
            imageView.image = resizedImage
            imageView.contentMode = .scaleAspectFill
            
            imageView.clipsToBounds = true
            return imageView
        }()
    }
    
    func addView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(commerceImageView)
        
        [accuaStackView, nanuaStackView, baccuaStackView, dasiStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        [accuaTitleLabel, accuaDescriptionLabel, accuaImageView, accuaDividerView].forEach {
            accuaStackView.addArrangedSubview($0)
        }
        
        for i in 0..<5 {
            nanuaImageView = {
                let imageView = UIImageView()
                let image = UIImage(named: "sampleImage")
                let resizedImage = image?.resized(to: CGSize(width: 35, height: 35))
                imageView.layer.cornerRadius = 10
                imageView.image = resizedImage
                imageView.contentMode = .scaleAspectFit
                
                imageView.clipsToBounds = true
                return imageView
            }()
            
            nanuaImageStackView.addArrangedSubview(nanuaImageView)
        }
        
        nanuaScrollView.addSubview(nanuaImageStackView)
        
        [nanuaTitleLabel, nanuaDescriptionLabel, nanuaScrollView, nanuaDividerView].forEach {
            nanuaStackView.addArrangedSubview($0)
        }
        [baccuaTitleLabel, baccuaDescriptionLabel, baccuaDividerView].forEach {
            baccuaStackView.addArrangedSubview($0)
        }
        [dasiTitleLabel, dasiDescriptionLabel, dasiImageView].forEach {
            dasiStackView.addArrangedSubview($0)
        }
    }
    
    func initLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeArea).inset(10)
        }
        
        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.verticalEdges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide).offset(-32)
        }
        
        commerceImageView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(contentStackView)
            $0.top.equalTo(contentStackView.snp.top)
        }
        accuaStackView.snp.makeConstraints {
            $0.top.equalTo(commerceImageView.snp.bottom)
            $0.width.equalTo(contentStackView.snp.width)
            $0.height.equalTo(200)
        }
        
        nanuaStackView.snp.makeConstraints {
            $0.top.equalTo(accuaStackView.snp.bottom)
            $0.width.equalTo(contentStackView.snp.width)
            //$0.height.equalTo(200)
        }
        
        baccuaStackView.snp.makeConstraints {
            $0.top.equalTo(nanuaStackView.snp.bottom)
            $0.width.equalTo(scrollView.snp.width)
            //$0.height.equalTo(200)
        }
        
        dasiStackView.snp.makeConstraints {
            $0.top.equalTo(baccuaStackView.snp.bottom)
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(200)
        }
        
        accuaTitleLabel.snp.makeConstraints {
            $0.top.equalTo(accuaStackView.snp.top)
        }
        accuaDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(accuaTitleLabel.snp.bottom)
        }
        accuaImageView.snp.makeConstraints {
            $0.top.equalTo(accuaDescriptionLabel.snp.bottom)
        }
        accuaDividerView.snp.makeConstraints {
            $0.top.equalTo(accuaImageView.snp.bottom)
            $0.height.equalTo(1)
            $0.width.equalTo(accuaStackView.snp.width)
        }
        
        nanuaTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nanuaStackView.snp.top)
        }
        nanuaDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nanuaTitleLabel.snp.bottom)
        }
        nanuaScrollView.snp.makeConstraints {
            $0.top.equalTo(nanuaDescriptionLabel.snp.bottom)
            $0.left.right.equalTo(nanuaStackView)
            $0.height.equalTo(40)
        }
        nanuaImageStackView.snp.makeConstraints {
            $0.top.equalTo(nanuaDescriptionLabel.snp.bottom)
        }
        nanuaDividerView.snp.makeConstraints {
            //$0.top.equalTo(nanuaDescriptionLabel.snp.bottom)
            $0.height.equalTo(1)
            $0.width.equalTo(nanuaStackView.snp.width)
        }
        
        baccuaTitleLabel.snp.makeConstraints {
            $0.top.equalTo(baccuaStackView.snp.top)
        }
        baccuaDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(baccuaTitleLabel.snp.bottom)
        }
        baccuaDividerView.snp.makeConstraints {
            $0.top.equalTo(baccuaDescriptionLabel.snp.bottom)
            $0.height.equalTo(1)
            $0.width.equalTo(baccuaStackView.snp.width)
        }
        
        dasiTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dasiStackView.snp.top)
        }
        dasiDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(dasiTitleLabel.snp.bottom)
        }
        dasiImageView.snp.makeConstraints {
            $0.top.equalTo(dasiDescriptionLabel.snp.bottom)
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
