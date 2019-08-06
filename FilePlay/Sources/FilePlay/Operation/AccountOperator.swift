//
//  AccountOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/7/25.
//

import Foundation
import PerfectHTTP

class AccountOperator: NSObject {
    // MARK: - 注册
    /**
     * params [String: Any]
     * 1. nickname 昵称
     * 2. mobile 注册手机
     * 3. password 密码
     */
    func registerHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        var nickname: String = ""
        
        if request.param(name: "nickname") != nil {
            nickname = request.param(name: "nickname")!
        }
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard nickname.count > 0 && mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = AccountModel().registerQuery(nickname: nickname, mobile: mobile, password: password)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 登录
    /**
     * params [String: Any]
     * 1. mobile 注册手机 (二选一)
     * 2. nickname 昵称 (二选一)
     * 3. password 新密码
     */
    func loginHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        var nickname: String = ""
        
        if request.param(name: "nickname") != nil {
            nickname = request.param(name: "nickname")!
        }
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard (nickname.count > 0 || mobile.count > 0) && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = AccountModel().loginQuery(mobile: mobile, nickname: nickname, password: password)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 修改用户信息
    /**
     * params [String: Any]
     * 1. userId 必填
     */
    func updateAccountHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0..<params.count {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count > 1 || dict["userId"] != nil else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = AccountModel().updateAccountQuery(params: dict)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 修改密码
    /**
     * params [String: Any]
     * 1. mobile 手机号
     * 2. password 新密码
     */
    func resetPasswordHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = AccountModel().resetPasswordQuery(mobile: mobile, password: password)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 获取用户信息
    /**
     * params [String: Any]
     * 1. userId 用户id
     */
    func accountInfoHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        guard userId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = AccountModel().accountQuery(userId: userId, mobile: "", loginId: "")
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 获取用户主页信息+收藏电影+动态列表
    /**
     * params [String: Any]
     * 1. userId 用户id
     * 2. loginId 登录用户id
     * 3. currentPage
     * 4. pageSize
     */
    func accountHomePageHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var loginId: String = ""
        var currentPage: String = ""
        var pageSize: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "currentPage") != nil {
            currentPage = request.param(name: "currentPage")!
        }
        
        if request.param(name: "pageSize") != nil {
            pageSize = request.param(name: "pageSize")!
        }
        
        guard userId.count > 0 && currentPage.count > 0 && pageSize.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        if Int(pageSize)! < 5 {
            pageSize = "5"
        }
        
        var dict: [String: Any] = [:]
        if Int(currentPage) == 0 {
            // MARK: - 用户信息
            let accountJson = AccountModel().accountQuery(userId: userId, mobile: "", loginId: loginId)
            let account = Utils.jsonToDictionary(accountJson)[ResultDataKey]
            dict["account"] = account
            
            // MARK: - 收藏影片总数
            dict["collectionCount"] = MovieModel().accountCollectionCountQuery(userId: userId)
            // MARK: - 我的影片 最多3个
            let collectionJson = MovieModel().accountCollectionListQuery(userId: userId, loginId: loginId, currentPage: 0, pageSize: 3)
            dict["collectionList"] = Utils.jsonToDictionary(collectionJson)[ResultDataKey]
        }
        
        // MARK: - 我的动态总页数
        dict["dynamicCount"] = DynamicModel().accountDynamicCountQuery(userId: userId)
        
        // MARK: - 我的动态
        let dynamicJson = DynamicModel().accountDynamicListQuery(userId: userId, loginId: loginId, currentPage: Int(currentPage)!, pageSize: Int(pageSize)!)
        dict["dynamicList"] = Utils.jsonToDictionary(dynamicJson)[ResultDataKey]
        
        let responseJson = Utils.successResponseJson(dict)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 用户粉丝列表 A(userId) 的粉丝列表 where userId==A
    /**
     * params [String: Any]
     * 1. userId 用户id
     * 2. loginId 登录用户id
     * 3. currentPage
     * 4. pageSize
     */
    func accountFanListHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var loginId: String = ""
        var currentPage: String = ""
        var pageSize: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "currentPage") != nil {
            currentPage = request.param(name: "currentPage")!
        }
        
        if request.param(name: "pageSize") != nil {
            pageSize = request.param(name: "pageSize")!
        }
        
        guard userId.count > 0 && currentPage.count > 0 && pageSize.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        if Int(pageSize)! < 5 {
            pageSize = "5"
        }
        
        let responseJson = AccountModel().accountAttentionFanListQuery(userId: userId, loginId: loginId, currentPage: Int(currentPage)!, pageSize: Int(pageSize)!, isAttention: false)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 用户关注列表 A 的关注列表 where authorId==A
    /**
     * params [String: Any]
     * 1. userId 用户id
     * 2. loginId 登录用户id
     * 3. currentPage
     * 4. pageSize
     */
    func accountAttentionListHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var loginId: String = ""
        var currentPage: String = ""
        var pageSize: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "currentPage") != nil {
            currentPage = request.param(name: "currentPage")!
        }
        
        if request.param(name: "pageSize") != nil {
            pageSize = request.param(name: "pageSize")!
        }
        
        guard userId.count > 0 && currentPage.count > 0 && pageSize.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        if Int(pageSize)! < 5 {
            pageSize = "5"
        }
        
        let responseJson = AccountModel().accountAttentionFanListQuery(userId: userId, loginId: loginId, currentPage: Int(currentPage)!, pageSize: Int(pageSize)!, isAttention: true)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 关注、取消关注
    /**
     * params [String: Any]
     * 1. userId 被关注人
     * 2. loginId 关注人
     */
    func accountAttentionStatusHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var loginId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        guard userId.count > 0 && loginId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = AccountModel().accountAttentionStatusQuery(userId: userId, loginId: loginId)
        response.appendBody(string: responseJson)
        response.completed()
    }
}
