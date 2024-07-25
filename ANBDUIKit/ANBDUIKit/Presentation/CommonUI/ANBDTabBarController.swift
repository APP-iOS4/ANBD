//
//  ANBDTabViewController.swift
//  ANBDUIKit
//
//  Created by 기 표 on 7/3/24.
//

import UIKit

class ANBDTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let articleVC = UINavigationController(rootViewController: ArticleViewController())
        let tradeVC = UINavigationController(rootViewController: TradeViewController())
        let chatVC = UINavigationController(rootViewController: ChatViewController())
        let myPageVC = UINavigationController(rootViewController: MyPageViewController())
        
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), tag: 0)
        articleVC.tabBarItem = UITabBarItem(title: "정보공유", image: UIImage(systemName: "leaf.fill"), tag: 1)
        tradeVC.tabBarItem = UITabBarItem(title: "나눔거래", image: UIImage(systemName: "arrow.3.trianglepath"), tag: 2)
        chatVC.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "bubble.right.fill"), tag: 3)
        myPageVC.tabBarItem = UITabBarItem(title: "내 정보", image: UIImage(systemName: "person.fill"), tag: 4)
        
        viewControllers = [homeVC, articleVC, tradeVC, chatVC, myPageVC]
    }
}
