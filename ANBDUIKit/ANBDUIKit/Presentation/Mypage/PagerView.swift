//
//  PagerView.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/2/24.
//

import UIKit
import SnapKit

final class PagerView: UIView {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout() // 수평스크롤, 아이템 간 간격 없앰
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false // 스크롤 바 숨김
        collectionView.isPagingEnabled = true // 페이지 단위 스크롤
        collectionView.backgroundColor = .systemGray5
        collectionView.clipsToBounds = true // 뷰 경계 밖에 있는 하위 뷰를 클립?
        collectionView.register(PagerCell.self, forCellWithReuseIdentifier: "pager")
        return collectionView
    }()
    
    private let items: [String]
    private let text: String
    var didEndScroll: ((Int) -> ())?
    
    init(items: [String], title: String) {
        self.items = items
        self.text = title
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) not implemented")
    }
    
    private func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PagerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pager", for: indexPath) as? PagerCell
        else { return UICollectionViewCell() }
        cell.prepare(title: "짱표님의 \(text)\n\(items[indexPath.row]) 활동이 없습니다.")
        return cell
    }
}

extension PagerView: UICollectionViewDelegate {
    // 스크롤이 멈추면 현재 페이지 인덱스를 계산해서 didEndScroll 클로저를 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let widthPerPage = scrollView.contentSize.width / CGFloat(items.count)
        let pageIndex = Int(scrollView.contentOffset.x / widthPerPage)
        didEndScroll?(pageIndex)
    }
}

extension PagerView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        frame.size
    }
}

extension PagerView: ScrollFitable {
    var scrollView: UIScrollView {
        collectionView
    }
    var countOfItems: Int {
        items.count
    }
}

// MARK: - PagerCell
final class PagerCell: UICollectionViewCell {
    // MARK: UI
    private let image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "tray")
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Initializer
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        contentView.addSubview(titleLabel)
        
        image.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(image.snp.bottom).offset(0)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        prepare(title: nil)
    }
    
    func prepare(title: String?) {
        titleLabel.text = title
    }
}
