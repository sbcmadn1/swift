//
//  UIBarButtonItem+Extension.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/29.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    // 扩展里面只能是便利构造函数
    convenience init(imageName: String) {
        let button = UIButton()
        
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "\(imageName)_highlighted"), forState: UIControlState.Highlighted)
        button.sizeToFit()
        
        self.init(customView: button)
    }
    
    /// 不创建对象就调用,生成一个带按钮的UIBarButtonItem
    class func navigaitonItem(imageName: String) -> UIBarButtonItem {
        let button = UIButton()
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "\(imageName)_highlighted"), forState: UIControlState.Highlighted)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
}
