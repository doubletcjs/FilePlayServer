//
//  AccountOperator.swift
//  FilePlay
//
//  Created by 万烨 on 2019/7/25.
//

import Foundation
import PerfectHTTP

class AccountOperator: DataBaseOperator {
    // MARK: - 手机号、昵称、用户id(三选一)是否存在
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - nickname: 昵称
    ///   - userId: 用户id
    /// - Returns: 0 不存在 1 已存在 2 查询失败
    private func checkAccount(mobile: String, nickname: String, userId: String) -> Int! {
        var statement = ""
        if mobile.count > 0 {
            statement = "SELECT userId FROM \(db_account) WHERE mobile = '\(mobile)'"
        }
        
        if nickname.count > 0 {
            statement = "SELECT userId FROM \(db_account) WHERE nickname = '\(nickname)'"
        }
        
        if userId.count > 0 {
            statement = "SELECT userId FROM \(db_account) WHERE userId = '\(userId)'"
        }
        
        if statement.count == 0 {
            return 2
        }
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户是否存在", mysql.errorMessage())
            return 2
        } else {
            var isExist = 0
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                isExist = 0
            } else {
                isExist = 1
            }
            
            return isExist
        }
    }
    // MARK: - 获取用户账号信息
    ///
    /// - Parameters:
    ///   - loginId: 登录用户id
    ///   - userId: 用户id
    ///   - mobile: 用户手机
    /// - Returns: 返回JSON数据
    private func accountSQL(userId: String, mobile: String, loginId: String) -> String {
        var response = Utils.failureResponseJson("用户注册，获取用户信息失败，请重新登录")
        let originalKeys: [String] = AccountModel.getAllPropertys()
        
        return response
    }
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
        
        func registerSQL() -> Void {
            // MARK: - 检查用户是否存在
            let nameStatus = checkAccount(mobile: "", nickname: nickname, userId: "")
            if nameStatus == 0 {
                // MARK: - 检查手机号码是否存在
                let mobileStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
                if mobileStatus == 0 {
                    let portrait = ""
                    let current = Date()
                    let date = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
                    
                    let values = "('\(mobile)', '\(password)', ('\(nickname)'), ('\(portrait)'), ('\(date)'))"
                    let statement = "INSERT INTO \(db_account) (mobile, password, nickname, portrait, date) VALUES \(values)"
                    
                    if mysql.query(statement: statement) == false {
                        Utils.logError("创建用户", mysql.errorMessage())
                        responseJson = Utils.failureResponseJson("用户注册失败")
                    } else {
                        // MARK: - 返回登录信息
                        responseJson = accountSQL(userId: "", mobile: mobile, loginId: "")
                    }
                } else if mobileStatus == 1 {
                    responseJson = Utils.failureResponseJson("该手机号码已被注册")
                } else if mobileStatus == 2 {
                    responseJson = Utils.failureResponseJson("用户注册失败")
                }
            } else if nameStatus == 1 {
                responseJson = Utils.failureResponseJson("该昵称已被注册")
            } else if nameStatus == 2 {
                responseJson = Utils.failureResponseJson("用户注册失败")
            }
        }
        
        registerSQL()
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
