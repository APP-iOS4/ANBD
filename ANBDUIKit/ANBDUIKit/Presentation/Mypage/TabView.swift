//
//  TabView.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/2/24.
//

import UIKit
import SnapKit

final class TabView: UIView {
    // MARK: UI
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 20
        stackView.axis = .horizontal
        return stackView
    }()
    
    let highlightView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    private var contentLabels = [UILabel]()
    
    // MARK: Property
    var dataSource: [String]? {
        didSet { setItems() }
    }
    var didTap: ((Int) -> Void)?
    private var selectedIndex: Int = 0
    
    // MARK: Initializer
    required init() {
        super.init(frame: .zero)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Method
    private func configure() {
        addSubview(stackView)
        addSubview(highlightView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setItems() {
        guard let items = dataSource else { return }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentLabels.removeAll()
        
        items.enumerated().forEach { offset, item in
            let label: UILabel = {
                let label = UILabel()
                label.text = item
                label.numberOfLines = 0
                label.font = .systemFont(ofSize: 16, weight: .semibold)
                label.textColor = offset == selectedIndex ? .black : .gray
                label.textAlignment = .center
                label.isUserInteractionEnabled = true
                label.tag = offset
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapItem))
                label.addGestureRecognizer(tapGesture)
                return label
            }()
            self.stackView.addArrangedSubview(label)
            self.contentLabels.append(label)
        }
        layoutIfNeeded()
        updateHighlightViewPosition()
    }
    
    @objc private func tapItem(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        didTap?(tag)
        updateSelectedIndex(to: tag)
    }
    
    func updateSelectedIndex(to newIndex: Int) {
        guard newIndex != selectedIndex else { return }
        contentLabels[selectedIndex].textColor = .gray
        contentLabels[newIndex].textColor = .black
        selectedIndex = newIndex
        updateHighlightViewPosition()
    }
    
    func updateHighlightViewPosition() {
        let selectedLabel = contentLabels[selectedIndex]
        UIView.animate(withDuration: 0.3) {
            self.highlightView.snp.remakeConstraints {
                $0.height.equalTo(3)
                $0.width.equalTo(selectedLabel.frame.width)
                $0.leading.equalTo(selectedLabel.snp.leading)
                $0.bottom.equalToSuperview()
            }
            self.layoutIfNeeded()
        }
    }

    func syncUnderlineView(index: Int, underlineView: UIView) {
        updateSelectedIndex(to: index) // 선택된 인덱스를 업데이트하고 텍스트 색상 변경
        updateHighlightViewPosition() // 하이라이트 뷰 위치 업데이트
    }
}

extension TabView: ScrollFitable {
    var tabContentViews: [UIView] {
        contentLabels
    }
    
    var scrollView: UIScrollView {
        return UIScrollView()
    }
    
    var countOfItems: Int {
        dataSource?.count ?? 0
    }
}
