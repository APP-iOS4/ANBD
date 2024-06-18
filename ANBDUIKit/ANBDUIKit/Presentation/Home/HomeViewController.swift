//
//  Home.swift
//  ANBDUIKit
//
//  Created by 최정인 on 5/31/24.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    // sample
    private var dataSource: [UIImage?] = {
        (1...5).map { _ in return UIImage(named: "sampleImage")}
    }()
    
    private lazy var moreButtonConfig = UIButton.Configuration.borderless()
    
    private lazy var pager = UIPageControl()
    private lazy var searchButton = UIBarButtonItem()
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    
    private lazy var commerceView = UIView()
    private lazy var commerceCollectionView = UICollectionView()
    private lazy var accuaStackView = UIStackView()
    private lazy var nanuaStackView = UIStackView()
    private lazy var baccuaStackView = UIStackView()
    private lazy var dasiStackView = UIStackView()
    
    private lazy var accuaTitleStackView = UIStackView()
    private lazy var accuaTitleLabel = UILabel()
    private lazy var accuaDescriptionLabel = UILabel()
    private lazy var accuaImageView = UIImageView()
    private var accuaDividerView = UIView()
    private var accuaMoreButton = UIButton()
    
    private lazy var nanuaTitleStackView = UIStackView()
    private lazy var nanuaTitleLabel = UILabel()
    private lazy var nanuaDescriptionLabel = UILabel()
    private var nanuaDividerView = UIView()
    private lazy var nanuaImageStackView = UIStackView()
    private lazy var nanuaImageView = UIImageView()
    private lazy var nanuaScrollView = UIScrollView()
    private lazy var nanuaCollectionView = UICollectionView()
    private var nanuaMoreButton = UIButton()
    
    private lazy var baccuaTitleStackView = UIStackView()
    private lazy var baccuaTitleLabel = UILabel()
    private lazy var baccuaDescriptionLabel = UILabel()
    private var baccuaDividerView = UIView()
    private var baccuaMoreButton = UIButton()
    private lazy var baccuaFirstCell = HomeTradeCell()
    private lazy var baccuaSecondCell = HomeTradeCell()
    
    private lazy var dasiTitleStackView = UIStackView()
    private lazy var dasiTitleLabel = UILabel()
    private lazy var dasiDescriptionLabel = UILabel()
    private lazy var dasiImageView = UIImageView()
    private var dasiMoreButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        initAttribute()
        addView()
        setCollectionView()
        initLayout()
    }
    
    func initAttribute() {
        searchButton.image = UIImage(systemName: "magnifyingglass")
        navigationItem.rightBarButtonItem = searchButton
        
        moreButtonConfig.title = "더보기"
        moreButtonConfig.image = UIImage(systemName: "chevron.right")
        moreButtonConfig.imagePlacement = .trailing
        moreButtonConfig.imagePadding = 5
        moreButtonConfig.baseForegroundColor = .black
        moreButtonConfig.buttonSize = .mini
        
        pager = {
            let pageControl = UIPageControl(frame: .zero)
            pageControl.currentPage = .zero
            pageControl.isUserInteractionEnabled = false
            pageControl.numberOfPages = dataSource.count
            
            pageControl.pageIndicatorTintColor = .systemGray2
            pageControl.currentPageIndicatorTintColor = .systemGray
            return pageControl
        }()
        
        scrollView = {
            let scrollView = UIScrollView()
            scrollView.showsVerticalScrollIndicator = false
            
            return scrollView
        }()
        contentStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 15
            
            return stackView
        }()
        
        accuaDividerView = {
            let view = UIView()
            view.backgroundColor = .systemGray5
            
            return view
        }()
        nanuaDividerView = {
            let view = UIView()
            view.backgroundColor = .systemGray5
            
            return view
        }()
        baccuaDividerView = {
            let view = UIView()
            view.backgroundColor = .systemGray5
            
            return view
        }()
        
        commerceView = {
            let view = UIView()
            
            return view
        }()
        commerceCollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: view.frame.width - 70, height: 150)
            
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.isScrollEnabled = true
            cv.showsHorizontalScrollIndicator = false
            cv.contentInset = .zero
            cv.backgroundColor = .clear
            cv.tag = 1
            
            return cv
        }()
        
        accuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 13
            return stackView
        }()
        nanuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 13
            return stackView
        }()
        baccuaStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 13
            return stackView
        }()
        dasiStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 13
            return stackView
        }()
        
        accuaTitleStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            return stackView
        }()
        accuaMoreButton = {
            let button = UIButton(configuration: moreButtonConfig)
            button.addTarget(self, action: #selector(accauMoreButtonAction), for: .touchUpInside)
            return button
        }()
        accuaTitleLabel = {
            let label = UILabel()
            label.text = "아껴쓰기"
            label.font = UIFont.boldSystemFont(ofSize: 22)
            
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
        
        nanuaTitleStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            return stackView
        }()
        nanuaMoreButton = {
            let button = UIButton(configuration: moreButtonConfig)
            return button
        }()
        nanuaTitleLabel = {
            let label = UILabel()
            label.text = "나눠쓰기"
            label.font = UIFont.boldSystemFont(ofSize: 22)
            
            return label
        }()
        nanuaDescriptionLabel = {
            let label = UILabel()
            label.text = "어쩌구 저쩌구 나눠쓰세용~~"
            
            return label
        }()
        nanuaCollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 150, height: 150)
            
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.isScrollEnabled = true
            cv.showsHorizontalScrollIndicator = false
            cv.contentInset = .zero
            cv.backgroundColor = .clear
            cv.tag = 2
            return cv
        }()
        
        baccuaTitleStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            return stackView
        }()
        baccuaMoreButton = {
            let button = UIButton(configuration: moreButtonConfig)
            return button
        }()
        baccuaTitleLabel = {
            let label = UILabel()
            label.text = "바꿔쓰기"
            label.font = UIFont.boldSystemFont(ofSize: 22)
            
            return label
        }()
        baccuaDescriptionLabel = {
            let label = UILabel()
            label.text = "어쩌구 저쩌구 바꿔쓰세용~~"
            
            return label
        }()
        baccuaFirstCell = {
            let cell = HomeTradeCell()
            cell.bind()
            return cell
        }()
        
        baccuaSecondCell = {
            let cell = HomeTradeCell()
            cell.bind()
            return cell
        }()
        
        dasiTitleStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            return stackView
        }()
        dasiMoreButton = {
            let button = UIButton(configuration: moreButtonConfig)
            return button
        }()
        dasiTitleLabel = {
            let label = UILabel()
            label.text = "다시쓰기"
            label.font = UIFont.boldSystemFont(ofSize: 22)
            
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
        
        commerceView.addSubview(commerceCollectionView)
        commerceView.addSubview(pager)
        
        contentStackView.addArrangedSubview(commerceView)
        
        [accuaStackView, nanuaStackView, baccuaStackView, dasiStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        [accuaTitleLabel, accuaMoreButton].forEach {
            accuaTitleStackView.addArrangedSubview($0)
        }
        [accuaTitleStackView, accuaDescriptionLabel, accuaImageView, accuaDividerView].forEach {
            accuaStackView.addArrangedSubview($0)
        }
        
        [nanuaTitleLabel, nanuaMoreButton].forEach {
            nanuaTitleStackView.addArrangedSubview($0)
        }
        [nanuaTitleStackView, nanuaDescriptionLabel, nanuaCollectionView, nanuaDividerView].forEach {
            nanuaStackView.addArrangedSubview($0)
        }
        
        [baccuaTitleLabel, baccuaMoreButton].forEach {
            baccuaTitleStackView.addArrangedSubview($0)
        }
        [baccuaTitleStackView, baccuaDescriptionLabel, baccuaFirstCell, baccuaSecondCell, baccuaDividerView].forEach {
            baccuaStackView.addArrangedSubview($0)
        }
        
        [dasiTitleLabel, dasiMoreButton].forEach {
            dasiTitleStackView.addArrangedSubview($0)
        }
        [dasiTitleStackView, dasiDescriptionLabel, dasiImageView].forEach {
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
        
        commerceView.snp.makeConstraints {
            $0.height.equalTo(150)
        }
        
        pager.snp.makeConstraints {
            $0.bottom.equalTo(commerceCollectionView.snp.bottom).inset(10)
            $0.centerX.equalTo(contentStackView)
        }
        
        commerceCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        nanuaCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        accuaDividerView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        nanuaDividerView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        baccuaDividerView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        baccuaFirstCell.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        baccuaSecondCell.snp.makeConstraints {
            $0.height.equalTo(100)
        }
    }
    
    func setCollectionView() {
        nanuaCollectionView.register(NanuaCollectionViewCell.self, forCellWithReuseIdentifier: "nanuaCell")
        nanuaCollectionView.dataSource = self
        nanuaCollectionView.delegate = self
        
        commerceCollectionView.register(CommerceCollectionViewCell.self, forCellWithReuseIdentifier: "CommerceCell")
        commerceCollectionView.dataSource = self
        commerceCollectionView.delegate = self
        //이거 작동 안 됨! ㅠ
        //        commerceCollectionView.isPagingEnabled = true
        //center로 paging 맞춰주기 위한 설정
        commerceCollectionView.decelerationRate = .fast
        commerceCollectionView.isPagingEnabled = false
    }
    
    @objc
    func accauMoreButtonAction() {
        let vc = ArticleViewController()
        vc.title = "아껴쓰기"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    // 셀 사이의 간격
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // 셀과 뷰의 간격
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 1 {
            return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        } else {
            return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        }
    }
    
    // 셀이 눌렸을 때
    //    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.commerceCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
        let estimatedIndex = scrollView.contentOffset.x / cellWidth
        let index: Int
        if velocity.x > 0 {
            index = Int(ceil(estimatedIndex))
        } else if velocity.x < 0 {
            index = Int(floor(estimatedIndex))
        } else {
            index = Int(round(estimatedIndex))
        }
        pager.currentPage = index
        
        targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidth, y: 0)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommerceCell", for: indexPath) as! CommerceCollectionViewCell
            cell.prepare(image: dataSource[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nanuaCell", for: indexPath) as! NanuaCollectionViewCell
            cell.prepare(image: dataSource[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
}
