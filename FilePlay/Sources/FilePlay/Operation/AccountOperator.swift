//
//  AccountOperator.swift
//  FilePlay
//
//  Created by 万烨 on 2019/7/25.
//

import Foundation
import PerfectHTTP

class AccountOperator: DataBaseOperator {
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
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0..<params.count {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 2 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 获取用户信息
    /**
     * params [String: Any]
     * 1. userId 用户id 或 用户手机
     * 2. loginId 登录用户id
     */
    func accountInfoHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var loginId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        guard userId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
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
        
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 修改密码
    /**
     * params [String: Any]
     * 1. mobile 注册手机
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
        
        response.appendBody(string: responseJson)
        response.completed()
    }
}
