//
//  CZPlaceholderTextView.swift
//  GZWeibo05
//
//  Created by zhangping on 15/11/4.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

class CZPlaceholderTextView: UITextView {
    
    // MARK: - 属性
    /// 占位文本
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            // 设置占位文本的font 等于 UITextView的font
            placeholderLabel.font = font
            
            placeholderLabel.sizeToFit()
        }
    }

    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        prepareUI()
        
        // 设置自己为代理,有风险,会被别人给覆盖
//        delegate = self
        // 改为使用通知来监听textView文本的改变
        // object: 通知的发送者
        // object: 如果填nil,任何人发送的 UITextViewTextDidChangeNotification都能监听
        // object: self表示只有自己发送的 UITextViewTextDidChangeNotification才能监听到
        NSNotificationCenter.defaultCenter() .addObserver(self, selector: "textDidChange", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    // 移除通知
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // 自己文字改变了
    func textDidChange() {
        // 能到这里来说明是当前这个textView文本改变了
        // 判断文本是否为空: hasText()
        // 当有文字的时候就隐藏
        placeholderLabel.hidden = hasText()
    }

    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        addSubview(placeholderLabel)
        
        // 添加约束
        placeholderLabel.ff_AlignInner(type: ff_AlignType.TopLeft, referView: self, size: nil, offset: CGPoint(x: 5, y: 8))
    }
    
    // MARK: - 懒加载
    // 添加占位文本
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel(fonsize: 18, textColor: UIColor.lightGrayColor())

        return label
    }()
}

// MARK: - 扩展 CZPlaceholderTextView 实现 UITextViewDelegate 协议
//extension CZPlaceholderTextView: UITextViewDelegate {
//    
//    /// 当textView文字改变的时候会调用
//    func textViewDidChange(textView: UITextView) {
//        // 判断文本是否为空: hasText()
//        // 当有文字的时候就隐藏
//        placeholderLabel.hidden = hasText()
//    }
//}