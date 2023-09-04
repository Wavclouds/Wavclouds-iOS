//
//  ViewController.swift
//  Rescupe
//
//  Created by Enoch Tamulonis on 8/21/23.
//

import UIKit

class ViewController: UINavigationController, UITabBarDelegate {
    let tabBar = UITabBar()
    let itemHome = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
    let itemPosts = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.frame = CGRect(x: 0, y: self.view.frame.height - 75, width: self.view.frame.width, height: 49)
        tabBar.items = [itemHome, itemPosts]
        self.view.addSubview(tabBar)
    }


}

