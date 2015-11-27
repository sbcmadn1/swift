//
//  CZNetworkTools.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/28.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit
import AFNetworking

// MARK: - 网络错误枚举
enum CZNetworkError: Int {
    case emptyToken = -1
    case emptyUid = -2
    
    // 枚举里面可以有属性
    var description: String {
        get {
            // 根据枚举的类型返回对应的错误
            switch self {
            case CZNetworkError.emptyToken:
                return "accecc token 为空"
            case CZNetworkError.emptyUid:
                return "uid 为空"
            }
        }
    }
    
    // 枚举可以定义方法
    func error() -> NSError {
        return NSError(domain: "cn.itcast.error.network", code: rawValue, userInfo: ["errorDescription" : description])
    }
}

class CZNetworkTools: NSObject {
    
    // 属性
    private var afnManager: AFHTTPSessionManager
    
    // 创建单例
    static let sharedInstance: CZNetworkTools = CZNetworkTools()
    
    override init() {
        let urlString = "https://api.weibo.com/"
        afnManager = AFHTTPSessionManager(baseURL: NSURL(string: urlString))
        afnManager.responseSerializer.acceptableContentTypes?.insert("text/plain")
    }

    // 创建单例
//    static let sharedInstance: CZNetworkTools = {
//        let urlString = "https://api.weibo.com/"
//        
//        let tool = CZNetworkTools(baseURL: NSURL(string: urlString))
////        Set
//        tool.responseSerializer.acceptableContentTypes?.insert("text/plain")
//        
//        return tool
//    }()
    
    // MARK: - OAtuh授权
    /// 申请应用时分配的AppKey
    private let client_id = "3769988269"
    
    /// 申请应用时分配的AppSecret
    private let client_secret = "8c30d1e7d3754eca9076689b91531c6a"
    
    /// 请求的类型，填写authorization_code
    private let grant_type = "authorization_code"
    
    /// 回调地址
    let redirect_uri = "http://www.baidu.com/"
    
    // OAtuhURL地址
    func oauthRUL() -> NSURL {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(client_id)&redirect_uri=\(redirect_uri)"
        return NSURL(string: urlString)!
    }
    
    // 使用闭包回调
    // MARK: - 加载AccessToken
    /// 加载AccessToken
    func loadAccessToken(code: String, finshed: NetworkFinishedCallback) {
        // url
        let urlString = "oauth2/access_token"
        
        // NSObject
        // AnyObject, 任何 class
        // 参数
        let parameters = [
            "client_id": client_id,
            "client_secret": client_secret,
            "grant_type": grant_type,
            "code": code,
            "redirect_uri": redirect_uri
        ]

        // 测试返回结果类型
//        responseSerializer = AFHTTPResponseSerializer()
        // result: 请求结果
        afnManager.POST(urlString, parameters: parameters, success: { (_, result) -> Void in
            
//            let data = String(data: result as! NSData, encoding: NSUTF8StringEncoding)
//            print("data: \(data)")
            
            finshed(result: result as? [String: AnyObject], error: nil)
            }) { (_, error: NSError) -> Void in
                finshed(result: nil, error: error)
        }
    }
    
    // MARK: - 获取用户信息
    func loadUserInfo(finshed: NetworkFinishedCallback) {
        
        // 守卫,和可选绑定相反
        // parameters 代码块里面和外面都能使用
        guard var parameters = tokenDict() else {
            // 能到这里来表示 parameters 没有值
            print("没有accessToken")
            
            let error = CZNetworkError.emptyToken.error()
            // 告诉调用者
            finshed(result: nil, error: error)
            return
        }
        
        // 判断uid
        if CZUserAccount.loadAccount()?.uid == nil {
            print("没有uid")
            let error = CZNetworkError.emptyUid.error()
            
            // 告诉调用者
            finshed(result: nil, error: error)
            return
        }
        
        // url
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        // 添加元素
        parameters["uid"] = CZUserAccount.loadAccount()!.uid!
        
        requestGET(urlString, parameters: parameters, finshed: finshed)
    }
    
    /// 判断access token是否有值,没有值返回nil,如果有值生成一个字典
    func tokenDict() -> [String: AnyObject]? {
        if CZUserAccount.loadAccount()?.access_token == nil {
            return nil
        }

        return ["access_token": CZUserAccount.loadAccount()!.access_token!]
    }
    
    // MARK: - 获取微博数据
    /**
    加载微博数据
    - parameter since_id: 若指定此参数，则返回ID比since_id大的微博,默认为0
    - parameter max_id:   若指定此参数，则返回ID小于或等于max_id的微博,默认为0
    - parameter finished: 回调
    */
    func loadStatus(since_id: Int, max_id: Int, finished: NetworkFinishedCallback) {
        guard var parameters = tokenDict() else {
            // 能到这里来说明token没有值
            
            // 告诉调用者
            finished(result: nil, error: CZNetworkError.emptyToken.error())
            return
        }
        
        // 添加参数 since_id和max_id
        // 判断是否有传since_id,max_id
        if since_id > 0 {
            parameters["since_id"] = since_id
        } else if max_id > 0 {
            parameters["max_id"] = max_id - 1
        }
        
        // access token 有值
        let urlString = "2/statuses/home_timeline.json"
        // 网络不给力,加载本地数据
        if true {
            requestGET(urlString, parameters: parameters, finshed: finished)
        } else {
            loadLocalStatus(finished)
        }
    }
    
    /// 加载本地微博数据
    private func loadLocalStatus(finished: NetworkFinishedCallback) {
        // 获取路径
        let path = NSBundle.mainBundle().pathForResource("statuses", ofType: "json")
        
        // 加载文件数据
        let data = NSData(contentsOfFile: path!)
        
        // 转成json
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
            // 有数据
            finished(result: json as? [String : AnyObject], error: nil)
        } catch {
            // 如果do里面的代码出错了,不会崩溃,会走这里
            print("出异常了")
        }
        
        // 强制try 如果这句代码有错误,程序立即停止运行
        // let statusesJson = try! NSJSONSerialization.JSONObjectWithData(nsData, options: NSJSONReadingOptions(rawValue: 0))
    }
    
    // MARK: - 发布微博
    /**
    发布微博
    - parameter image:   微博图片,可能有可能没有
    - parameter status:   微博文本内容
    - parameter finished: 回调闭包
    */
    func sendStatus(image: UIImage?, status: String, finished: NetworkFinishedCallback) {
        // 判断token
        guard var parameters = tokenDict() else {
            // 能到这里来说明token没有值
            
            // 告诉调用者
            finished(result: nil, error: CZNetworkError.emptyToken.error())
            return
        }
        
        // token有值, 拼接参数
        parameters["status"] = status
        
        
        // 判断是否有图片
        if let im = image {
            // 有图片,发送带图片的微博
            let urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
            
            afnManager.POST(urlString, parameters: parameters, constructingBodyWithBlock: { (formData) -> Void in
                let data = UIImagePNGRepresentation(im)!
                
                // data: 上传图片的2进制
                // name: api 上面写的传递参数名称 "pic"
                // fileName: 上传到服务器后,保存的名称,没有指定可以随便写
                // mimeType: 资源类型:
                    // image/png
                    // image/jpeg
                    // image/gif
                formData.appendPartWithFileData(data, name: "pic", fileName: "sb", mimeType: "image/png")
                }, success: { (_, result) -> Void in
                    finished(result: result as? [String: AnyObject], error: nil)
                }, failure: { (_, error) -> Void in
                    finished(result: nil, error: error)
            })
        } else {
            // url
            let urlString = "2/statuses/update.json"
            // 没有图片
            afnManager.POST(urlString, parameters: parameters, success: { (_, result) -> Void in
                finished(result: result as? [String: AnyObject], error: nil)
                }) { (_, error) -> Void in
                    finished(result: nil, error: error)
            }
        }
        
    }
    
    // 类型别名 = typedefined
    typealias NetworkFinishedCallback = (result: [String: AnyObject]?, error: NSError?) -> ()
    
    // MARK: - 封装AFN.GET
    func requestGET(URLString: String, parameters: AnyObject?, finshed: NetworkFinishedCallback) {
        
        afnManager.GET(URLString, parameters: parameters, success: { (_, result) -> Void in
            finshed(result: result as? [String: AnyObject], error: nil)
            }) { (_, error) -> Void in
                finshed(result: nil, error: error)
        }
    }
}
