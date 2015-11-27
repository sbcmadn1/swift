//
//  CZMainViewController.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/26.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

class CZMainViewController: UITabBarController {
    
    func composeButtonClick() {
        // __FUNCTION__ 打印方法名称
//        print(__FUNCTION__)
        
        // 判断如果没有登录,就到登陆界面,否则就到发微博界面
        let vc = CZUserAccount.userLogin() ? CZComposeViewController() : CZOauthViewController()
        
        // 弹出对应的控制器
        presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        let newTabBar = CZMainTabBar()
        
//        newTabBar.composeButton.addTarget(self, action: "composeButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
        // 使用KVC
//        setValue(newTabBar, forKey: "tabBar")
        
        tabBar.tintColor = UIColor.orangeColor()

        // 首页
        let homeVC = CZHomeTableViewController()
        self.addChildViewController(homeVC, title: "首页", imageName: "tabbar_home")
        
        // 消息
        let messageVC = CZMessageTableViewController()
        self.addChildViewController(messageVC, title: "消息", imageName: "tabbar_message_center")
        
        let controller = UIViewController()
        
        // CUICatalog: Invalid asset name supplied:
        self.addChildViewController(controller, title: "", imageName: "f")
        
        // 发现
        let discoverVC = CZDiscoverTableViewController()
        self.addChildViewController(discoverVC, title: "发现", imageName: "tabbar_discover")
        
        // 我
        let profileVC = CZProfileTableViewController()
        self.addChildViewController(profileVC, title: "我", imageName: "tabbar_profile")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let width = tabBar.bounds.width / CGFloat(5)
        composeButton.frame = CGRect(x: width * 2, y: 0, width: width, height: tabBar.bounds.height)
        tabBar.addSubview(composeButton)
    }
    
    /**
    添加子控制器,包装Nav
    - parameter controller: 控制器
    - parameter title:      标题
    - parameter imageName:  图片名称
    */
    private func addChildViewController(controller: UIViewController, title: String, imageName: String) {
        controller.title = title
        controller.tabBarItem.image = UIImage(named: imageName)
        addChildViewController(UINavigationController(rootViewController: controller))
    }
    
    // MARK: - 懒加载
    /// 撰写按钮
    lazy var composeButton: UIButton = {
        let button = UIButton()
        
        // 按钮图片
        button.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        
        // 按钮的背景
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        
        button.addTarget(self, action: "composeButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
}
