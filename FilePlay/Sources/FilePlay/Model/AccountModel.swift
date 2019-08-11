//
//  AccountModel.swift
//  FilePlay
//
//  Created by 4work on 2019/8/1.
//

import Foundation

class AccountModel: DataBaseOperator {
    class func getAllPropertys() -> [String] {
        return [
            "userId",
            "nickname",
            "portrait",
            "gender",
            "mobile",
            "date",
            "introduce"];
    }
    
    // MARK: - 基本内容
    /**
     *     用户id
     */
    @objc var userId: String = ""
    /**
     *    用户名(昵称)
     */
    @objc var nickname: String = ""
    /**
     *    头像
     */
    @objc var portrait: String = ""
    /**
     *     性别 0 未设置 1 男 2 女
     */
    @objc var gender: Int = 0
    /**
     *    手机号码
     */
    @objc var mobile: String = ""
    /**
     *    创建日期 yyyy-MM-dd
     */
    @objc var date: String = ""
    /**
     *    简介
     */
    @objc var introduce: String = ""
/*
    // MARK: - 联表查询
    /**
     *     是否关注
     */
    @objc var isAttention: Bool = false
    /**
     *     关注
     */
    @objc var attentionCount: Int = 0
    /**
     *     粉丝
     */
    @objc var fanCount: Int = 0
*/
 
    // MARK: - 手机号、昵称、用户id(三选一)是否存在
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - nickname: 昵称
    ///   - userId: 用户id
    /// - Returns: 0 不存在 1 已存在 2 查询失败
    private func checkAccountQuery(mobile: String, nickname: String, userId: String) -> Int! {
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
            let results = mysql.storeResults()
            if results?.numRows() == 0 {
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
    ///   - userId: 用户id 二选一
    ///   - mobile: 用户手机 二选一
    /// - Returns: 返回 用户信息
    func accountQuery(userId: String, mobile: String, loginId: String) -> String {
        let accountStatus = checkAccountQuery(mobile: mobile, nickname: "", userId: userId)
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("获取用户信息失败")
        } else {
            var originalKeys: [String] = AccountModel.getAllPropertys()
            //关注、粉丝数
            originalKeys.append("attentionCount")
            originalKeys.append("fanCount")
            
            var tableKeys: [String] = [
                "\(db_account).userId",
                "\(db_account).nickname",
                "\(db_account).portrait",
                "\(db_account).gender",
                "\(db_account).mobile",
                "\(db_account).date",
                "\(db_account).introduce"]
            
            //关注、粉丝数
            tableKeys.append("COUNT(DISTINCT db_account_attention.authorId) attentionCount")
            tableKeys.append("COUNT(DISTINCT db_account_fan.userId) fanCount")
            
            //关注、粉丝数
            var contingency: [String] = [
                "LEFT JOIN \(db_attention_fan) db_account_attention ON (db_account_attention.authorId = \(db_account).userId)",
                "LEFT JOIN \(db_attention_fan) db_account_fan ON (db_account_fan.userId = \(db_account).userId)"]
            
            if loginId.count > 0 && loginId != userId {
                //是否关注
                originalKeys.append("isAttention")
                tableKeys.append("COUNT(DISTINCT \(db_attention_fan).objectId) isAttention")
                contingency.append("LEFT JOIN \(db_attention_fan) ON (\(db_attention_fan).authorId = '\(loginId)' AND \(db_attention_fan).userId = '\(userId)')")
            }
            
            //查询条件
            var whereStatement = ""
            if userId.count > 0 {
                whereStatement = "\(db_account).userId = '\(userId)'"
            }
            
            if mobile.count > 0 {
                whereStatement = "\(db_account).mobile = '\(mobile)'"
            }
            
            let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_account) \(contingency.joined(separator: " ")) WHERE \(whereStatement)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("获取用户信息", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("获取用户信息失败")
            } else {
                let results = mysql.storeResults()
                if results!.numRows() > 0 {
                    var dict: [String: Any] = [:]
                    results?.forEachRow { (row) in
                        for idx in 0..<row.count {
                            let key = originalKeys[idx]
                            dict["\(key)"] = row[idx]! as Any
                        }
                    }
                    
                    if dict["isAttention"] != nil {
                        if Int(dict["isAttention"] as! String) != 0 {
                            dict["isAttention"] = true
                        } else {
                            dict["isAttention"] = false
                        }
                    }
                    
                    responseJson = Utils.successResponseJson(dict)
                } else {
                    responseJson = Utils.failureResponseJson("获取用户信息失败")
                }
            }
        }
        
        return responseJson
    }
    // MARK: - 注册
    /**
     * params [String: Any]
     * 1. nickname 昵称
     * 2. mobile 注册手机
     * 3. password 密码
     */
    /// - Parameters:
    ///   - mobile: 注册手机
    ///   - nickname: 昵称
    ///   - password: 密码
    /// - Returns: 用户信息
    func registerQuery(nickname: String, mobile: String, password: String) -> String {
        // MARK: - 检查用户是否存在
        let nameStatus = self.checkAccountQuery(mobile: "", nickname: nickname, userId: "")
        if nameStatus == 0 {
            // MARK: - 检查手机号码是否存在
            let mobileStatus = self.checkAccountQuery(mobile: mobile, nickname: "", userId: "")
            if mobileStatus == 0 {
                let portrait = ""
                let current = Date()
                let date = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
                
                let values = "('\(mobile)', '\(password)', ('\(Utils.fixSingleQuotes(nickname))'), ('\(portrait)'), ('\(date)'))"
                let statement = "INSERT INTO \(db_account) (mobile, password, nickname, portrait, date) VALUES \(values)"
                
                if mysql.query(statement: statement) == false {
                    Utils.logError("创建用户", mysql.errorMessage())
                    responseJson = Utils.failureResponseJson("用户注册失败")
                } else {
                    // MARK: - 返回登录信息
                    responseJson = self.accountQuery(userId: "", mobile: mobile, loginId: "")
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
        
        return responseJson
    }
    // MARK: - 登录
    /**
     * params [String: Any]
     * 1. mobile 注册手机 (二选一)
     * 2. nickname 昵称 (二选一)
     * 3. password 密码
     */
    /// - Parameters:
    ///   - mobile: 注册手机
    ///   - nickname: 昵称
    ///   - password: 密码
    /// - Returns: 用户信息
    func loginQuery(mobile: String, nickname: String, password: String) -> String {
        let accountStatus = checkAccountQuery(mobile: mobile, nickname: nickname, userId: "")
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("登录失败")
        } else {
            var whereStatement = ""
            if mobile.count > 0 {
                whereStatement = "mobile = '\(mobile)'"
            }
            
            if nickname.count > 0 {
                whereStatement = "nickname = '\(nickname)'"
            }
            
            let statement = "SELECT userId, password FROM \(db_account) WHERE \(whereStatement)"
            if mysql.query(statement: statement) == false {
                Utils.logError("账号密码登录", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("登录失败")
            } else {
                let results = mysql.storeResults()
                var passwd = ""
                var userId = ""
                results?.forEachRow { (row) in
                    for _ in 0..<row.count {
                        passwd = row[1]!
                        userId = row[0]!
                        break
                    }
                }
                
                if passwd == password {
                    responseJson = self.accountQuery(userId: userId, mobile: mobile, loginId: "")
                } else {
                    responseJson = Utils.failureResponseJson("密码错误")
                }
            }
        }
        
        return responseJson
    }
    // MARK: - 修改用户信息
    /**
     * params [String: Any]
     * 1. userId 必填
     */
    /// - Parameters:
    ///   - params: [String: Any]
    /// - Returns: 用户信息
    func updateAccountQuery(params: [String: Any]) -> String {
        let userId: String = params["userId"] as! String
        
        let accountStatus = self.checkAccountQuery(mobile: "", nickname: "", userId: userId)
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("更新用户信息失败")
        } else {
            func updateInfo() -> Void {
                var contentValue: [String] = []
                params.keys.forEach { (key) in
                    if key != "userId" {
                        var value = params[key]
                        if value is String {
                            value = Utils.fixSingleQuotes(value as! String)
                        }
                        
                        contentValue.append("\(key) = '\(value!)'")
                    }
                }
                
                let statement = "UPDATE \(db_account) SET \(contentValue.joined(separator: ", ")) WHERE userId = '\(userId)'"
                if mysql.query(statement: statement) == false {
                    Utils.logError("更新用户信息", mysql.errorMessage())
                    responseJson = Utils.failureResponseJson("更新用户信息失败")
                } else {
                    responseJson = self.accountQuery(userId: userId, mobile: "", loginId: "")
                }
            }
            
            if params["nickname"] != nil {
                let nickname: String = params["nickname"] as! String
                if self.checkAccountQuery(mobile: "", nickname: nickname, userId: "") == 1 {
                    responseJson = Utils.failureResponseJson("昵称已被占用")
                } else {
                    updateInfo()
                }
            } else {
                updateInfo()
            }
        }
        
        return responseJson
    }
    // MARK: - 修改密码
    /**
     * params [String: Any]
     * 1. mobile 手机号
     * 2. password 新密码
     */
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - password: 新密码
    /// - Returns: 成功、失败
    func resetPasswordQuery(mobile: String, password: String) -> String {
        let accountStatus = self.checkAccountQuery(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("修改密码失败")
        } else {
            let statement = "SELECT password FROM \(db_account) WHERE mobile = '\(mobile)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("密码检验", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("密码检验失败")
            } else {
                let results = mysql.storeResults()
                var passwd = ""
                results?.forEachRow { (row) in
                    for idx in 0..<row.count {
                        passwd = row[idx]!
                        break
                    }
                }
                
                if passwd == password {
                    responseJson = Utils.failureResponseJson("新密码与原密码相同")
                } else {
                    let statement = "UPDATE \(db_account) SET password = '\(password)' WHERE mobile = '\(mobile)'"
                    if mysql.query(statement: statement) == false {
                        Utils.logError("重置密码", mysql.errorMessage())
                        responseJson = Utils.failureResponseJson("密码修改失败")
                    } else {
                        responseJson = Utils.successResponseJson("密码修改成功")
                    }
                }
            }
        }
        
        return responseJson
    }
    // MARK: - 用户粉丝列表
    /// 用户关注列表 A 的关注列表 where authorId==A
    /// 用户粉丝列表 A 的粉丝列表 where userId==A
    /// - Parameters:
    ///   - userId: 用户id
    ///   - loginId: 当前登录用户id
    ///   - currentPage: 当前页
    ///   - pageSize: pageSize
    /// - Returns: 用户动态数
    func accountAttentionFanListQuery(userId: String, loginId: String, currentPage: Int, pageSize: Int, isAttention: Bool) -> String {
        var type = "userId"
        var typeName = "粉丝"
        if isAttention == true {
            type = "authorId"
            typeName = "关注"
        }
        
        var originalKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender"]
        
        var tableKeys: [String] = [
            "\(db_account).userId",
            "\(db_account).nickname",
            "\(db_account).portrait",
            "\(db_account).gender"]
        
        var statements: [String] = ["LEFT JOIN \(db_account) ON (\(db_account).userId = \(db_attention_fan).userId)"]
        if loginId.count > 0 {
            originalKeys.append("isAttention")
            tableKeys.append("COUNT(DISTINCT db_attentionFan.objectId) isAttention")
            statements.append("LEFT JOIN \(db_attention_fan) db_attentionFan ON (db_attentionFan.authorId = '\(loginId)')")
        }
        
        let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_attention_fan) \(statements.joined(separator: " ")) WHERE \(db_attention_fan).\(type) = '\(userId)' GROUP BY \(db_attention_fan).objectId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户\(typeName)列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户\(typeName)列表查询失败")
        } else {
            var fanList = [[String: Any]]()
            let results = mysql.storeResults()
            results?.forEachRow { (row) in
                var dict: [String: Any] = [:]
                for idx in 0..<row.count {
                    let key = originalKeys[idx]
                    let value = row[idx]
                    dict[key] = value
                    
                    if dict["isAttention"] != nil {
                        if Int(dict["isAttention"] as! String) != 0 {
                            dict["isAttention"] = true
                        } else {
                            dict["isAttention"] = false
                        }
                    }
                }
                
                fanList.append(dict)
            }
            
            responseJson = Utils.successResponseJson(fanList)
        }
        
        return responseJson
    }
    // MARK: - 关注、取消关注
    /// - Parameters:
    ///   - userId: 被关注人
    ///   - loginId: 关注人
    /// - Returns: 返回JSON数据 状态 0 查询失败 不改变状态 1 已关注 2 未关注
    func accountAttentionStatusQuery(userId: String, loginId: String) -> String {
        let tableName = db_attention_fan
        // 状态 0 查询失败 不改变状态 1 已关注 2 未关注
        func isAttention() -> Int {
            let statement = "SELECT COUNT(DISTINCT \(tableName).objectId) attentionCount FROM \(tableName) WHERE \(tableName).authorId = '\(loginId)' AND \(tableName).userId = '\(userId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("是否关注用户", mysql.errorMessage())
                return 0
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    var status: Int = 2
                    results.forEachRow { (row) in
                        for idx in 0..<row.count {
                            let value = row[idx]! as String
                            if Int(value)! > 0 {
                                status = 1
                            }
                        }
                    }
                    
                    return status
                } else {
                    return 0
                }
            }
        } 
        
        if isAttention() == 1 {
            // 取消关注
            let statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).userId = '\(userId)' AND \(tableName).authorId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("取消关注", mysql.errorMessage())
                responseJson = Utils.successResponseJson("0")
            } else {
                responseJson = Utils.successResponseJson("\(isAttention())")
            }
        } else if isAttention() == 2 {
            // 添加关注
            let statement = "INSERT INTO \(tableName) (authorId, userId) VALUES ('\(loginId)', '\(userId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("添加关注", mysql.errorMessage())
                responseJson = Utils.successResponseJson("0")
            } else {
                responseJson = Utils.successResponseJson("\(isAttention())")
            }
        } else {
            responseJson = Utils.successResponseJson("0")
        }
    
        return responseJson
    }
}
