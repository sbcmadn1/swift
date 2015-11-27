//
//  CZRefreshControl.swift
//  GZWeibo05
//
//  Created by zhangping on 15/11/3.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

class CZRefreshControl: UIRefreshControl {
    // MARK: - 属性
    // 箭头旋转的值
    private let RefreshControlOffest: CGFloat = -60
    
    // 标记, 用于除去重复答应
    private var isUp = false
    
    /// 覆盖父类的frame属性
    override var frame: CGRect {
        didSet {
//            print("frame:\(frame)")
            
            if frame.origin.y >= 0 {
                return
            }
            
            // 判断系统的刷新控件是否正在刷新
            if refreshing {
                // 调用自定义的view,开始旋转
                refreshView.startLoading()
            }
            
            // !isUp表示之前是朝下的
            if frame.origin.y < RefreshControlOffest && !isUp {
                print("箭头转上去")
                isUp = true
                refreshView.rotationTipViewIcon(isUp)
            } else if frame.origin.y > RefreshControlOffest && isUp {   // 0 - 60
                print("箭头转下去")
                isUp = false
                refreshView.rotationTipViewIcon(isUp)
            }
        }
    }
    
    // 重写 endRefreshing
    override func endRefreshing() {
        super.endRefreshing()
        
        // 停止旋转
        refreshView.stopLoading()
    }
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        prepareUI()
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        addSubview(refreshView)
        print("refreshView:\(refreshView)")
        
        // 添加约束
        refreshView.ff_AlignInner(type: ff_AlignType.CenterCenter, referView: self, size: refreshView.bounds.size)
    }

    // MARK: - 懒加载
    /// 自定的刷新view, 从xib里面加载出来view的fram就有了
    private lazy var refreshView: CZRefreshView = CZRefreshView.refreshView()
}

// 自定义刷新的view
class CZRefreshView: UIView {
    
    /// 旋转的view
    @IBOutlet weak var loadingView: UIImageView!
    
    //
    @IBOutlet weak var tipView: UIView!
    
    // 箭头
    @IBOutlet weak var tipViewIcon: UIImageView!
    
    // 加载xib
    class func refreshView() -> CZRefreshView {
        return NSBundle.mainBundle().loadNibNamed("CZRefreshView", owner: nil, options: nil).last as! CZRefreshView
    }
    
    /**
    箭头旋转动画
    - parameter isUp: true,表示朝上, false,朝下
    */
    func rotationTipViewIcon(isUp: Bool) {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.tipViewIcon.transform = isUp ? CGAffineTransformMakeRotation(CGFloat(M_PI - 0.01)) : CGAffineTransformIdentity
        }
    }
    
    /// 开始旋转
    func startLoading() {
        // 如果动画正在执行,不添加动画
        let animKey = "animKey"
        // 获取图层上所有正在执行的动画的key
        if let _ = loadingView.layer.animationForKey(animKey) {
            // 找到对应的动画,动画正在执行,直接返回
            return
        }
        
        tipView.hidden = true
        
        // 旋转
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = M_PI * 2
        anim.duration = 0.25
        anim.repeatCount = MAXFLOAT
        
        anim.removedOnCompletion = false
        
        // 开始动画,如果名称一样,会先停掉正在执行的,在重新添加
        loadingView.layer.addAnimation(anim, forKey: animKey)
    }
    
    /// 停止旋转
    func stopLoading() {
        // 显示tipView
        tipView.hidden = false
        
        // 停止旋转
        loadingView.layer.removeAllAnimations()
    }
}