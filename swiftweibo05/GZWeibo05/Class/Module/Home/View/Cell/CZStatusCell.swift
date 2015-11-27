//
//  CZStatusCell.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/31.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

let StatusCellMargin: CGFloat = 8

// cell父类
class CZStatusCell: UITableViewCell {
    
    // MARK: - 属性
    /// 配图宽度约束
    var pictureViewWidthCon: NSLayoutConstraint?
    
    /// 配图高度约束
    var pictureViewHeightCon: NSLayoutConstraint?
    
    /// 微博模型
    var status: CZStatus? {
        didSet {
//            print("\(status?.idstr),父类监视器")
            
            // 将模型赋值给 topView
            topView.status = status
            
            // 将模型赋值给配图视图
            pictureView.status = status
            
            // 调用模型的计算尺寸的方法
            let size = pictureView.calcViewSize()
//            print("配图size: \(size)")
            
            // 重新设置配图的宽高约束
            pictureViewWidthCon?.constant = size.width
            pictureViewHeightCon?.constant = size.height
            
            // 设置微博内容
            contentLabel.text = status?.text
            
            // TODO: 测试配图的高度
            // 测试配图的高度,行数是随机不固定的
//            let row =  arc4random_uniform(1000) % 4
//            pictureViewHeightCon?.constant = CGFloat(row) * 90
        }
    }
    
    // 设置cell的模型,cell会根据模型,从新设置内容,更新约束.获取子控件的最大Y值
    // 返回cell的高度
    func rowHeight(status: CZStatus) -> CGFloat {
        // 设置cell的模型
        self.status = status
        
        // 更新约束
        layoutIfNeeded()
        
        // 获取子控件的最大Y值
        let maxY = CGRectGetMaxY(bottomView.frame)
        
        return maxY
    }

    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareUI()
    }
    
    // MARK: - 准备UI
    func prepareUI() {
        // 添加子控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)
        
        // 添加约束
        topView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: contentView, size: CGSize(width: UIScreen.width(), height: 53))
        
        // 微博内容
        contentLabel.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: topView, size: nil, offset: CGPoint(x: StatusCellMargin, y: StatusCellMargin))
        
        // 设置宽度
        contentView.addConstraint(NSLayoutConstraint(item: contentLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UIScreen.width() - 2 * StatusCellMargin))
        
//        // 微博配图
        // 因为转发微博需要设置配图约束,不能再这里设置配图的约束,需要在创建一个cell继承CZStatusCell,添加上配图的约束
//        let cons = pictureView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: CGSize(width: 0, height: 0), offset: CGPoint(x: 0, y: StatusCellMargin))
//        
//        // 获取配图的宽高约束
//        pictureViewHeightCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
//        pictureViewWidthCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        
        // 底部视图
        bottomView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: pictureView, size: CGSize(width: UIScreen.width(), height: 44), offset: CGPoint(x: -StatusCellMargin, y: StatusCellMargin))
        
        // 添加contentView底部和bottomView的底部重合
//        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    }
    
    // MARK: - 懒加载
    /// 顶部视图
    private lazy var topView: CZStatusTopView = CZStatusTopView()
    
    /// 微博内容
    lazy var contentLabel: UILabel = {
        let label = UILabel(fonsize: 16, textColor: UIColor.blackColor())
        
        // 显示多行
        label.numberOfLines = 0
        
        return label
    }()
    
    /// 微博配图
    lazy var pictureView: CZStatusPictureView = CZStatusPictureView()
    
    /// 底部视图
    lazy var bottomView: CZStatusBottomView = CZStatusBottomView()
}
