//
//  ScrollFitable.swift
//  ANBD_UIKit
//
//  Created by 기 표 on 6/2/24.
//

import UIKit

private struct AssociatedKeys {
    static var lastWidthKey = "lastWidth"
}

// 하나의 기능 단위로 취급할 수 있으므로 프로토콜로 구현
protocol ScrollFitable: AnyObject {
    // 스크롤 피팅시킬 떄 사용
    var scrollView: UIScrollView { get }
    
    // 아이템의 갯수를 파악해서 아이템 하나의 갯수를 알아낼 수 있도록
    var countOfItems: Int { get }
    
    // 스크롤되는 위치를 결정할 때 해당 뷰의 rect값을 알면 scrollRectToVisible(_:animated:)로 쉽게 스크롤 가능하므로
    var tabContentViews: [UIView] { get }

    // TabView에서 아이템을 탭됐을 때 해당 index값을 가져오고 그 값을 가지고 pagerView를 스크롤 시킬 때 사용
    func scroll(to index: Int)
    
    // pagerView에서 스크롤될 때 전체에서 어느정도 스크롤 되었는지를 ratio값으로 알 수 있는데 이 값을 가지고 tabView를 스크롤할 때 사용
    func scroll(to ratio: Double)
}

extension ScrollFitable {
    var lastWidth: Double {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastWidthKey) as? Double ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var tabContentViews: [UIView] {
        []
    }
    
    /* 스크롤 처리 2단계로 하는 이유, 핵심
        - didScroll 델리게이트에서 넘어올때는 실수 값을 받아서 x좌표의 레이아웃을 정의
        - DidEndDecelerating 델리게이트에서 넘어올때는 정수 값을 받아서 width값도 업데이트
        (나누는 이유: didScroll에서도 정수 값을 받아서 업데이트 하면 스크롤이 진행될때 정수이므로 실시간으로 스크롤이 안됨)
        
        - lastWidth를 따로 두는 이유도, didScroll에서 width값도 같이 업데이트 되는데 이 값은 이전값으로 놓기 위함
     */
    
    func scroll(to index: Int) {
        if index < tabContentViews.count {
            scrollView.scroll(rect: tabContentViews[index].frame, animated: true)
        } else {
            let offset = getStartOffset(index: index)
            scrollView.setContentOffset(offset, animated: true)
        }
    }
    
    func scroll(to ratio: Double) {
        let rect = getTargetRect(ratio: ratio)
        scrollView.scroll(rect: rect, animated: true)
    }
    
    // 핵심: 뷰 기준으로 해야 width값을 뷰의 동적 사이즈 대응이 가능
    func syncUnderlineView(index: Int, underlineView: UIView) {
        guard index < tabContentViews.count else { return }
        let targetLabel = tabContentViews[index]
        lastWidth = targetLabel.frame.width
        
        underlineView.snp.remakeConstraints {
            $0.width.equalTo(targetLabel)
            $0.height.equalTo(2)
            $0.leading.equalTo(targetLabel)
            $0.bottom.equalTo(-5)
        }
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveLinear,
            animations: { self.scrollView.layoutIfNeeded() }
        )
    }
    
    // 핵심: 뷰 기준으로 정하면 안됨 (view기준으로하면 뚝뚝 끊기는 스크롤이 되므로 실수값으로 해야함)
    func syncUnderlineView(ratio: Double, underlineView: UIView) {
        let leading = scrollView.contentSize.width * ratio
        
        underlineView.snp.remakeConstraints {
            $0.width.equalTo(lastWidth)
            $0.height.equalTo(2)
            $0.leading.equalTo(leading)
            $0.bottom.equalTo(-5)
        }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            animations: { self.scrollView.layoutIfNeeded() }
        )
    }
    
    private func getStartOffset(index: Int) -> CGPoint {
        let totalWidth = scrollView.contentSize.width
        let widthPerItem = totalWidth / Double(countOfItems)
        let startOffsetX = widthPerItem * Double(index)
        return .init(
            x: startOffsetX,
            y: scrollView.contentOffset.y
        )
    }
    
    private func getTargetRect(ratio: Double) -> CGRect {
        let totalWidth = scrollView.contentSize.width
        
        let rect = CGRect(
            x: totalWidth * ratio,
            y: scrollView.frame.minY,
            width: scrollView.frame.width,
            height: scrollView.frame.height
        )
        return rect
    }
}

// 핵심: 스크롤을 원하는 곳의 중앙에 위치시킴 (https://ios-development.tistory.com/1262)
private extension UIScrollView {
    func scroll(rect: CGRect, animated: Bool) {
        let origin = CGPoint(
            x: rect.origin.x - (frame.width - rect.size.width) / 2,
            y: rect.origin.y - (frame.height - rect.size.height) / 2
        )
        let rect = CGRect(origin: origin, size: frame.size)
        
        scrollRectToVisible(rect, animated: animated)
    }
}
