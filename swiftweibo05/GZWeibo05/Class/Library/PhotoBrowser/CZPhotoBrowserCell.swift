//
//  CZPhotoBrowserCell.swift
//  GZWeibo05
//
//  Created by zhangping on 15/11/7.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

/// 自定义cell
class CZPhotoBrowserCell: UICollectionViewCell {
    
    // MARK: - 属性
    /// 要显示图片的url地址
    var url: NSURL? {
        didSet {
            // 下载图片
            guard let imageURL = url else {
                print("imageURL 为空")
                return
            }
            
            // 将imageView图片设置为nil,防止cell重用
            imageView.image = nil
            
            // 显示下载指示器
            indicator.startAnimating()
            // 使用sd去下载
            self.imageView.sd_setImageWithURL(imageURL) { (image, error, _, _) -> Void in
                // 关闭指示器
                self.indicator.stopAnimating()
                if error != nil {
                    print("下载大图片出错:error: \(error), url:\(imageURL)")
                    return
                }
                
                // 下载成功, 设置imageView的大小
                print("下载成功")
                self.layoutImageView(image)
            }
        }
    }
    
//    private func testAfter() {
//        // 模拟网络延时
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
//            // 使用sd去下载
//            self.imageView.sd_setImageWithURL(imageURL) { (image, error, _, _) -> Void in
//                // 关闭指示器
//                self.indicator.stopAnimating()
//                if error != nil {
//                    print("下载大图片出错:error: \(error), url:\(imageURL)")
//                    return
//                }
//                
//                // 下载成功, 设置imageView的大小
//                print("下载成功")
//                self.layoutImageView(image)
//            }
//        }
//    }
    
    /*
        等比例缩放到宽度等于屏幕的宽度后:
            1.高度大于等于屏幕的高度 -> 长图
            2.高度小于屏幕的高度 -> 短图
    */
    
    /// 根据长短图,重新布局imageView
    private func layoutImageView(image: UIImage) {
        // 获取等比例缩放后的图片大小
        let size = displaySize(image)
        
        // 判断长短图
        if size.height < UIScreen.height() {
            // 短图, 居中显示
            
            let offestY = (UIScreen.height() - size.height) * 0.5
            
            imageView.frame = CGRect(x: 0, y: offestY, width: size.width, height: size.height)
        } else {
            // 长图, 顶部显示
            imageView.frame = CGRect(origin: CGPointZero, size: size)
            
            // 设置滚动
            scrollView.contentSize = size
        }
    }
    
    /*
        将图片等比例缩放, 缩放到图片的宽度等屏幕的宽度
    */
    private func displaySize(image: UIImage) -> CGSize {
        // 新的高度 / 新的宽度 = 原来的高度 / 原来的宽度
        
        // 新的宽度
        let newWidth = UIScreen.width()
        
        // 新的高度
        let newHeight = newWidth * image.size.height / image.size.width
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    private func prepareUI() {
        // 添加子控件
        contentView.addSubview(scrollView)
        // 提示
        scrollView.addSubview(imageView)
        
        contentView.addSubview(indicator)
        
        // 设置scrollView的缩放
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 0.5
        scrollView.delegate = self
        
//        scrollView.backgroundColor = UIColor.redColor()
        
        // 添加约束
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[sv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sv" : scrollView]))
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sv" : scrollView]))
        
        // imageView的大小不固定.等获取到图片来计算
        
        // 进度指示器
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    // MARK: - 懒加载
    /// scrollView
    private lazy var scrollView = UIScrollView()
    
    /// imageView
    private lazy var imageView = UIImageView()
    
    /// 下载图片提示
    private lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
}

// MARK: - 扩展CZPhotoBrowserCell 实现 UIScrollViewDelegate 协议
extension CZPhotoBrowserCell: UIScrollViewDelegate {
    /// 返回需要缩放的view
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /*
        print("imageView.frame:\(imageView.frame)")
        print("imageView.bounds:\(imageView.bounds)")
        缩放后frame会改变.bounds不会改变
    */
    /// scrollView缩放完毕调用
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        print("缩放完毕")
    }
    
    /// scrollView缩放时调用
    func scrollViewDidZoom(scrollView: UIScrollView) {
        print("缩放时")
    }
}