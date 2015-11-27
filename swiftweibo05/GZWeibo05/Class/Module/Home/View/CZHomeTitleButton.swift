//
//  CZHomeTitleButton.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/31.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

class CZHomeTitleButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 改变箭头位置
        titleLabel?.frame.origin.x = 0
        
        imageView?.frame.origin.x = titleLabel!.frame.width + 3
    }

}
