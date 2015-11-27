//
//  CZVistorView.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/26.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

/*
    使用frame:
        origin: 指定位置
        size:  指定尺寸大小

*/

// 定义协议
protocol CZVistorViewDelegte: NSObjectProtocol {
    func vistorViewRegistClick()
    
    func vistorViewLoginClick()
}

class CZVistorView: UIView {
    
    // 属性
    weak var vistorViewDelegate: CZVistorViewDelegte?
    
    // MARK: - 按钮点击事件
    /// 注册
    func registClick() {
//        if let delegate = vistorViewDelegate {
//            delegate.vistorViewRegistClick()
//        } else {
//            print("妹子")
//        }
        // ? 前面的变量有值才执行后面的代码,没有值就什么都不做
        vistorViewDelegate?.vistorViewRegistClick()
    }
    
    /// 登录
    func loginClick() {
        vistorViewDelegate?.vistorViewLoginClick()
    }

    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    // MARK: - 设置访客视图内容
    /**
    设置访客视图内容,出了首页
    - parameter imageName: 图片名称
    - parameter message:   消息
    */
    func setupVistorView(imageName: String, message: String) {
        // 隐藏房子
        homeView.hidden = true
        
        iconView.image = UIImage(named: imageName)
        
        messageLabel.text = message
        
        self.sendSubviewToBack(coverView)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(iconView.layer.animationKeys())
    }
    
    // 转轮动画
    func startRotationAnimation() {
        // 创建动画
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        // 设置参数
        animation.toValue = 2 * M_PI
        animation.repeatCount = MAXFLOAT
        animation.duration = 20
        
        // 完成的时候不移除
        animation.removedOnCompletion = false
        
        // 开始动画
        iconView.layer.addAnimation(animation, forKey: "homeRotation")
    }
    
    /// 暂停旋转
    func pauseAnimation() {
        // 记录暂停时间
        let pauseTime = iconView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        
        // 设置动画速度为0
        iconView.layer.speed = 0
        
        // 设置动画偏移时间
        iconView.layer.timeOffset = pauseTime
    }
    
    /// 恢复旋转
    func resumeAnimation() {
        // 获取暂停时间
        let pauseTime = iconView.layer.timeOffset
        
        // 设置动画速度为1
        iconView.layer.speed = 1
        
        iconView.layer.timeOffset = 0
        
        iconView.layer.beginTime = 0
        
        let timeSincePause = iconView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pauseTime
        
        iconView.layer.beginTime = timeSincePause
    }
    
    /// 准备UI
    func prepareUI() {
        // 设置背景
        backgroundColor = UIColor(white: 237.0 / 255, alpha: 1)
        
        // 添加子控件
        addSubview(iconView)
        // 遮盖
        addSubview(coverView)
        addSubview(homeView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        // 设置约束
        iconView.translatesAutoresizingMaskIntoConstraints = false
        coverView.translatesAutoresizingMaskIntoConstraints = false
        homeView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建约束
        // view1.attr1 = view2.attr2 * multiplier + constant
        
        // 转轮
        // CenterX
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        // CenterY
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -40))
        
        // 小房子
        // x
        addConstraint(NSLayoutConstraint(item: homeView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: homeView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // 消息label
        // x
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        // y
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        // width
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 240))
        
        // 注册按钮
        // 左边
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        // 顶部
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        
        // 宽度
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        
        // 高度
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // 登录按钮
        // 右边
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        // 顶部
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        
        // 宽度
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        
        // 高度
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // 遮盖
        // 左边
        addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        // 上边
        addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
        // 右边
        addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        // 下边
        addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: registerButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    }
    
    func test() {
        // 创建约束
        // view1.attr1 = view2.attr2 * multiplier + constant
        // CenterX
        let cX = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.addConstraint(cX)
        
        // CenterY
        let cY = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.addConstraint(cY)
    }

    // MARK: - 懒加载
    /// 转轮
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        
        // 设置图片
        let image = UIImage(named: "visitordiscover_feed_image_smallicon")
        imageView.image = image
        
        imageView.sizeToFit()
        
        return imageView
    }()
    
    /// 小房子.只有首页有
    private lazy var homeView: UIImageView = {
        let imageView = UIImageView()
        
        // 设置图片
        let image = UIImage(named: "visitordiscover_feed_image_house")
        imageView.image = image
        
        imageView.sizeToFit()
        
        return imageView
    }()
    
    /// 消息文字
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        
        // 设置文字
        label.text = "关注一些人,看看有什么惊喜"
        
        label.textColor = UIColor.lightGrayColor()
        
        label.numberOfLines = 0
        
        label.sizeToFit()
        
        return label
    }()
    
    /// 注册按钮
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        
        // 设置文字
        button.setTitle("注册", forState: UIControlState.Normal)
        
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        
        // 设置背景
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        button.sizeToFit()
        
        // 添加点击事件
        button.addTarget(self, action: "registClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
    
    /// 登录按钮
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        
        // 设置文字
        button.setTitle("登录", forState: UIControlState.Normal)
        
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        // 设置背景
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        button.sizeToFit()
        
        // 添加点击事件
        button.addTarget(self, action: "loginClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
    
    // 遮盖
    private lazy var coverView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
}
