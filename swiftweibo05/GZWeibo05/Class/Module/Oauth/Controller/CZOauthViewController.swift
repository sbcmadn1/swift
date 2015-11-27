//
//  CZOauthViewController.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/28.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit
import SVProgressHUD

class CZOauthViewController: UIViewController {

    override func loadView() {
        view = webView
        
        // 设置代理
        webView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 没有的背景颜色的时候modal出来的时候动画奇怪
//        view.backgroundColor = UIColor.brownColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "填充", style: UIBarButtonItemStyle.Plain, target: self, action: "autoFill")
        
        // 加载网页
        let request = NSURLRequest(URL: CZNetworkTools.sharedInstance.oauthRUL())
        webView.loadRequest(request)
    }
    
    /// 自动填充账号密码
    func autoFill() {
        let js = "document.getElementById('userId').value='czbkiosweibo@163.com';" + "document.getElementById('passwd').value='czbkiosczbkios';"
        
        // webView执行js代码
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    /// 关闭控制器
    func close() {
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - 懒加载
    private lazy var webView = UIWebView()
}

// MARK: - 扩展 CZOauthViewController 实现 UIWebViewDelegate 协议
extension CZOauthViewController: UIWebViewDelegate {
    
    /// 开始加载请求
    func webViewDidStartLoad(webView: UIWebView) {
        // 显示正在加载
        // showWithStatus 不主动关闭,会一直显示
        SVProgressHUD.showWithStatus("正在玩命加载...", maskType: SVProgressHUDMaskType.Black)
    }
    
    /// 加载请求完毕
    func webViewDidFinishLoad(webView: UIWebView) {
        // 关闭
        SVProgressHUD.dismiss()
    }
    
    /// 询问是否加载 request
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlString = request.URL!.absoluteString
        print("urlString:\(urlString)")
        
        // 加载的不是回调地址
        if !urlString.hasPrefix(CZNetworkTools.sharedInstance.redirect_uri) {
            return true // 可以加载
        }
        
        // http://www.baidu.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330
        // http://www.baidu.com/?code=8b56fa06bebf7dc058696c2b2897767e
        
        // 如果点击的是确定或取消截拦截不加载
        if let query = request.URL?.query {
            print("query:\(query)")
            let codeString = "code="
            
            if query.hasPrefix(codeString) {
                // 确定
                // code=8b56fa06bebf7dc058696c2b2897767e
                // 转成NSString
                let nsQuery = query as NSString
                
                // 截取code的值
                let code = nsQuery.substringFromIndex(codeString.characters.count)
                print("code: \(code)")
                // 获取access token
                loadAccessToken(code)
            } else {
                // 取消
                
            }
        }
        
        return false
    }
    
    /**
    调用网络工具类去加载加载access token
    - parameter code: code
    */
    func loadAccessToken(code: String) {
        CZNetworkTools.sharedInstance.loadAccessToken(code) { (result, error) -> () in
            if error != nil || result == nil {
//                SVProgressHUD.showErrorWithStatus("网络不给力...", maskType: SVProgressHUDMaskType.Black)
//                
//                // 延迟关闭. dispatch_after 没有提示,可以拖oc的dispatch_after来修改
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
//                    self.close()
//                })
                self.netError("网络不给力...")
                
                return
            }
            
            print("result: \(result)")
            let account = CZUserAccount(dict: result!)
            
            // 保存到沙盒
            account.saveAccount()
            
            // 加载用户数据
            account.loadUserInfo({ (error) -> () in
                if error != nil {
                    print("加载用户数据出错: \(error)")
                    self.netError("加载用户数据出错...")
                    return
                }
                
                print("account:\(CZUserAccount.loadAccount())")
                self.close()
                
                // 切换控制器
                (UIApplication.sharedApplication().delegate as! AppDelegate).switchRootController(false)
            })
        }
    }
    
    private func netError(message: String) {
        SVProgressHUD.showErrorWithStatus(message, maskType: SVProgressHUDMaskType.Black)
        
        // 延迟关闭. dispatch_after 没有提示,可以拖oc的dispatch_after来修改
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.close()
        })
    }
}