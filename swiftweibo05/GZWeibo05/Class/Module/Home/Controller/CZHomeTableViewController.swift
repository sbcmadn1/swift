//
//  CZHomeTableViewController.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/26.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

// 统一管理cell的ID
enum CZStatusCellIdentifier: String {
    case NormalCell = "NormalCell"
    case ForwardCell = "ForwardCell"
}

class CZHomeTableViewController: CZBaseTableViewController {
    
    // MARK: - 属性
    /// 微博模型数组
    private var statuses: [CZStatus]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !CZUserAccount.userLogin() {
            return
        }
        
        setupNavigaiotnBar()
        prepareTableView()
        
        // 注册配图点击后的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedPicture:", name: CZStatusPictureViewCellSelectedPictureNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// 配图视图 cell 点击的 处理方法
    func selectedPicture(notification: NSNotification) {
//        print("notification:\(notification)")
        
        guard let urls = notification.userInfo?[CZStatusPictureViewCellSelectedPictureURLKey] as? [NSURL] else {
            print("urls有问题")
            return
        }
        
        guard let index = notification.userInfo?[CZStatusPictureViewCellSelectedPictureIndexKey] as? Int else {
            print("index有问题")
            return
        }
        
        // 弹出控制器
        let photoBrowserVC = CZPhotoBrowserViewController(urls: urls, selectedIndex: index)
        
        presentViewController(photoBrowserVC, animated: true, completion: nil)
    }
    
    
    func loadData() {
        // TODO: 测试获取微博数据
        print("加载微博数据")
        // 默认下拉刷新,获取id最大的微博, 如果没有数据,就默认加载20
        var since_id = statuses?.first?.id ?? 0
        var max_id = 0
        
        // 如果菊花正在转,表示 上拉加载更多数据
        if pullUpView.isAnimating() {
            // 上拉加载更多数据
            since_id = 0
            max_id = statuses?.last?.id ?? 0 // 设置为最后一条微博的id
        }
        
        CZStatus.loadStatus(since_id, max_id: max_id) { (statuses, error) -> () in
            // 关闭下拉刷新控件
            self.refreshControl?.endRefreshing()
            
            // 将菊花停止
            self.pullUpView.stopAnimating()
            
            if error != nil {
                SVProgressHUD.showErrorWithStatus("加载微博数据失败,网络不给力", maskType: SVProgressHUDMaskType.Black)
                
                return
            }
            
            
            // 下拉刷新,显示加载了多少条微博
            if since_id > 0 {
                let count = statuses?.count ?? 0
                self.showTipView(count)
            }
            
            // 能到下面来说明没有错误
            if statuses == nil || statuses?.count == 0 {
                SVProgressHUD.showInfoWithStatus("没有新的微博数据", maskType: SVProgressHUDMaskType.Black)
                return
            }
            
            // 判断如果是下拉刷新,加获取到数据拼接在现有数据的前
            if since_id > 0 {   // 下拉刷新
                // 最新数据 =  新获取到的数据 + 原有的数据
                print("下拉刷新,获取到: \(statuses?.count)");
                self.statuses = statuses! + self.statuses!
            } else if max_id > 0 {  // 上拉加载更多数据
                // 最新数据 =  原有的数据 + 新获取到的数据
                print("上拉加载更多数据,获取到: \(statuses?.count)");
                self.statuses = self.statuses! + statuses!
            } else {
                // 有微博数据
                self.statuses = statuses
                print("获取最新20条数据.获取到 \(statuses?.count) 条微博")
            }
            
        }
    }
    
    /// 显示下拉刷新加载了多少条微博
    private func showTipView(count: Int) {
        let tipLabelHeight: CGFloat = 44
        let tipLabel = UILabel()
        tipLabel.frame = CGRect(x: 0, y: -20 - tipLabelHeight, width: UIScreen.width(), height: tipLabelHeight)
        
        tipLabel.textColor = UIColor.whiteColor()
        tipLabel.backgroundColor = UIColor.orangeColor()
        tipLabel.font = UIFont.systemFontOfSize(16)
        tipLabel.textAlignment = NSTextAlignment.Center
        
        tipLabel.text = count == 0 ? "没有新的微博" : "加载了 \(count) 条微博"
        
        // 导航栏是从状态栏下面开始
        // 添加到导航栏最下面
        navigationController?.navigationBar.insertSubview(tipLabel, atIndex: 0)
        
        let duration = 0.75
        // 开始动画
        UIView.animateWithDuration(duration, animations: { () -> Void in
            // 让动画反过来执行
//            UIView.setAnimationRepeatAutoreverses(true)
            
            // 重复执行
//            UIView.setAnimationRepeatCount(5)
            tipLabel.frame.origin.y = tipLabelHeight
            }) { (_) -> Void in
                
                UIView.animateWithDuration(duration, delay: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    tipLabel.frame.origin.y = -20 - tipLabelHeight
                    }, completion: { (_) -> Void in
                        tipLabel.removeFromSuperview()
                })
        }
    }
    
    private func prepareTableView() {
        // 添加footView,上拉加载更多数据的菊花
        tableView.tableFooterView = pullUpView
        
        // talbeView注册cell
        // 原创微博cell
        tableView.registerClass(CZStatusNormalCell.self, forCellReuseIdentifier: CZStatusCellIdentifier.NormalCell.rawValue)
        // 转发微博cell
        tableView.registerClass(CZStatusForwardCell.self, forCellReuseIdentifier: CZStatusCellIdentifier.ForwardCell.rawValue)
        
        // 去掉tableView的分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        tableView.rowHeight = 200
        
        // 设置预估行高,行高要尽量准确,不要太小
//        tableView.estimatedRowHeight = 30
        
        // AutomaticDimension 根据约束自己来设置高度
        // "<NSLayoutConstraint:0x7fb96d838530 'UIView-Encapsulated-Layout-Height' V:[UITableViewCellContentView:0x7fb96d8b40a0(255)]>
        // 当配图的高度约束修改后,添加bottomView的底部和contenView底部重合,导致系统计算cell高度约束出错.不能让系统来根据子控件的约束来计算contentView高度约束
//        tableView.rowHeight = 500
        
        // 默认高度60,宽度是屏幕的宽度
        // 自定义 UIRefreshControl,在 自定义的UIRefreshControl添加自定义的view
        refreshControl = CZRefreshControl()
        //        print(refreshControl)
        // 添加下拉刷新响应事件
        refreshControl?.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        
        // 调用beginRefreshing开始刷新,但是不会触发 ValueChanged 事件,只会让刷新控件进入刷新状态
        refreshControl?.beginRefreshing()
        
        // 代码触发 refreshControl 的 ValueChanged 事件
        refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        //        // TODO: 测试添加view
        //        let view = UIView()
        //        view.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        //        view.backgroundColor = UIColor.redColor()
        //        refreshControl?.addSubview(view)
        //        refreshControl?.tintColor = UIColor.clearColor()
        
        //        loadData()
    }
    
    /// 设置导航栏
    private func setupNavigaiotnBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendsearch")
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop")
        
        // 获取用户名
        // ??:  如果?? 前面有值,拆包 赋值给 name,如果没有值 将?? 后面的内容赋值给 name
        let name = CZUserAccount.loadAccount()?.name ?? "没有名称"
        // 设置title
        let button = CZHomeTitleButton()
        
        button.setTitle(name, forState: UIControlState.Normal)
        button.setImage(UIImage(named: "navigationbar_arrow_down"), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.sizeToFit()
        
        button.addTarget(self, action: "homeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        navigationItem.titleView = button
    }
    
    // OC可以访问 private方法
    @objc private func homeButtonClick(button: UIButton) {
        button.selected = !button.selected
        
        var transform: CGAffineTransform?
        if button.selected {
            transform = CGAffineTransformMakeRotation(CGFloat(M_PI - 0.01))
        } else {
            transform = CGAffineTransformIdentity
        }
        
        UIView.animateWithDuration(0.25) { () -> Void in
            button.imageView?.transform = transform!
        }
    }
    
    // MARK: - tableView 代理和数据源
    
    // 使用 这个方法,会再次调用 heightForRowAtIndexPath,造成死循环
    //        tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    // 返回cell的高度,如果每次都去计算行高,消耗性能,缓存行高,将行高缓存到模型里面
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // 获取模型
        let status = statuses![indexPath.row]
        
        // 去模型里面查看之前有没有缓存行高
        if let rowHeight = status.rowHeight {
            // 模型有缓存的行高
//            print("返回cell: \(indexPath.row), 缓存的行高:\(rowHeight)")
            return rowHeight
        }
        // 没有缓存的行高
        
        let id = status.cellID()
        // 获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier(id) as! CZStatusCell
        
        // 调用cell计算行高的方法
        let rowHeight = cell.rowHeight(status)
//        print("计算: \(indexPath.row), cell高度: \(rowHeight)")
        
        // 将行高缓存起来
        status.rowHeight = rowHeight
        
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 获取模型
        let status = statuses![indexPath.row]
        // 获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier(status.cellID()) as! CZStatusCell
        
        // 设置cell的模型
        cell.status = status
        
        // 当最后一个cell显示的时候来加载更多微博数据
        // 如果菊花正在显示,就表示正在加载数据,就不加载数据
        if indexPath.row == statuses!.count - 1 && !pullUpView.isAnimating() {
            // 菊花转起来
            pullUpView.startAnimating()
            
            // 上拉加载更多数据
            loadData()
        }
        
        return cell
    }
    
    // MARK: - 懒加载
    /// 上拉加载更多数据显示的菊花
    private lazy var pullUpView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
        indicator.color = UIColor.magentaColor()
        
        return indicator
    }()
}
