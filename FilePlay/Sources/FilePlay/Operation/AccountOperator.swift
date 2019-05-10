//
//  AccountOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/3/8.
//

import Foundation

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
            statement = "SELECT userId FROM \(accounttable) WHERE mobile = '\(mobile)'"
        }
        
        if nickname.count > 0 {
            statement = "SELECT userId FROM \(accounttable) WHERE nickname = '\(nickname)'"
        }
        
        if userId.count > 0 {
            statement = "SELECT userId FROM \(accounttable) WHERE userId = '\(userId)'"
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
    // MARK: - 获取我的账号(登录)信息
    ///
    /// - Parameters:
    ///   - loginId: 登录用户id
    ///   - userId: 用户id
    ///   - mobile: 用户手机
    /// - Returns: 返回JSON数据
    func getAccount(userId: String, mobile: String, loginId: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: userId)
        if accountStatus == 1 {
            let originalKeys: [String] = [
                "userId",
                "nickname",
                "portrait",
                "gender",
                "mobile",
                "date",
                "introduce",
                "reportCount",
                "attentionCount",
                "fanCount",
                "watchCount",
                "wantCount",
                "dynamicCount",
                "isAttention"]
            
            var keys: [String] = [
                "\(accounttable).userId",
                "\(accounttable).nickname",
                "\(accounttable).portrait",
                "\(accounttable).gender",
                "\(accounttable).mobile",
                "\(accounttable).date",
                "\(accounttable).introduce",
                "COUNT(DISTINCT \(reportusertable).objectId) reportCount",
                "COUNT(DISTINCT attention.authorId) attentionCount",
                "COUNT(DISTINCT fan.userId) fanCount",
                "COUNT(DISTINCT \(watchmovietable).objectId) watchCount",
                "COUNT(DISTINCT \(wantmovietable).objectId) wantCount",
                "COUNT(DISTINCT \(dynamictable).objectId) dynamicCount"]
            
            var countConditions: [String] = [
                "LEFT JOIN \(reportusertable) ON (\(reportusertable).userId = \(accounttable).userId)",
                "LEFT JOIN \(attentionfantable) attention ON (attention.authorId = \(accounttable).userId)",
                "LEFT JOIN \(attentionfantable) fan ON (fan.userId = \(accounttable).userId)",
                "LEFT JOIN \(watchmovietable) ON (\(watchmovietable).userId = \(accounttable).userId)",
                "LEFT JOIN \(wantmovietable) ON (\(wantmovietable).userId = \(accounttable).userId)",
                "LEFT JOIN \(dynamictable) ON (\(dynamictable).authorId = \(accounttable).userId)"]
            
            if loginId.count > 0 {
                keys.append("COUNT(DISTINCT \(attentionfantable).objectId) isAttention")
                countConditions.append("LEFT JOIN \(attentionfantable) ON (\(attentionfantable).authorId = '\(loginId)' AND \(attentionfantable).userId = '\(userId)')")
            }
            
            var whereStatement = ""
            if userId.count > 0 {
                whereStatement = "\(accounttable).userId = '\(userId)'"
            }
            
            if mobile.count > 0 {
                whereStatement = "\(accounttable).mobile = '\(mobile)'"
            }
            
            let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(accounttable) \(countConditions.joined(separator: " ")) WHERE \(whereStatement) GROUP BY \(accounttable).userId"
            if mysql.query(statement: statement) == false {
                Utils.logError("获取用户信息", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("获取用户信息失败")
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    var dict: [String: Any] = [:]
                    var keys: [String] = originalKeys
                    
                    results.forEachRow { (row) in
                        for idx in 0...row.count-1 {
                            let key = keys[idx]
                            dict["\(key)"] = row[idx]! as Any
                        }
                    }
                    
                    if dict["isAttention"] != nil {
                        if Int(dict["isAttention"] as! String) != 0 {
                            dict["isAttention"] = true
                        } else {
                            dict["isAttention"] = false
                        }
                    } else {
                        dict["isAttention"] = false
                    }
                    
                    responseJson = Utils.successResponseJson(dict)
                } else {
                    responseJson = Utils.failureResponseJson("获取用户信息失败")
                }
            }
        } else if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("获取用户信息失败")
        }
        
        return responseJson
    }
    // MARK: - 注册用户名
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - password: 密码
    /// - Returns: 返回JSON数据
    func registerAccount(mobile: String, password: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            let nickname = ""
            let portrait = ""
            
            let current = Date()
            let date = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
            
            let values = "('\(mobile)', '\(password)', ('\(nickname)'), ('\(portrait)'), ('\(date)'))"
            let statement = "INSERT INTO \(accounttable) (mobile, password, nickname, portrait, date) VALUES \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("创建用户", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("用户注册失败")
            } else {
                //返回登录信息
                responseJson = self.getAccount(userId: "", mobile: mobile, loginId: "")
            }
        } else if accountStatus == 1 {
            responseJson = Utils.failureResponseJson("该手机号码已被注册")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("用户注册失败")
        }
        
        return responseJson
    }
    // MARK: - 账号密码登录
    ///
    /// - Parameters:
    ///   - params: 参数 mobile 手机号 （nickname 昵称） password 密码
    /// - Returns: 返回JSON数据
    func passwordLogin(params: [String: Any]) -> String {
        var mobile: String = ""
        if params["mobile"] != nil {
            mobile = params["mobile"] as! String
        }
        
        var nickname: String = ""
        if params["nickname"] != nil {
            nickname = params["nickname"] as! String
        }
        
        if mobile.count == 0 && nickname.count == 0 {
            responseJson = Utils.failureResponseJson("账号不能为空，手机号或昵称")
        } else {
            let password: String = params["password"] as! String
            
            let accountStatus = checkAccount(mobile: mobile, nickname: nickname, userId: "")
            if accountStatus == 0 {
                responseJson = Utils.failureResponseJson("用户不存在")
            } else if accountStatus == 1 {
                var whereStatement = ""
                if mobile.count > 0 {
                    whereStatement = "mobile = '\(mobile)'"
                }
                
                if nickname.count > 0 {
                    whereStatement = "nickname = '\(nickname)'"
                }
                
                let statement = "SELECT userId, password FROM \(accounttable) WHERE \(whereStatement)"
                
                if mysql.query(statement: statement) == false {
                    Utils.logError("账号密码登录", mysql.errorMessage())
                    responseJson = Utils.failureResponseJson("登录失败")
                } else {
                    let results = mysql.storeResults()!
                    var passwd = ""
                    var userId = ""
                    results.forEachRow { (row) in
                        for _ in 0...row.count-1 {
                            passwd = row[1]!
                            userId = row[0]!
                            break
                        }
                    }
                    
                    if passwd == password {
                        responseJson = self.getAccount(userId: userId, mobile: mobile, loginId: "")
                    } else {
                        responseJson = Utils.failureResponseJson("密码错误")
                    }
                }
            } else if accountStatus == 2 {
                responseJson = Utils.failureResponseJson("登录失败")
            }
        }
        
        return responseJson
    }
    // MARK: - 重置密码
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - password: 新密码
    /// - Returns: 返回JSON数据
    func resetPassword(mobile: String, password: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 1 {
            let statement = "SELECT password FROM \(accounttable) WHERE mobile = '\(mobile)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("密码检验", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("密码检验失败")
            } else {
                let results = mysql.storeResults()!
                var passwd = ""
                results.forEachRow { (row) in
                    for idx in 0...row.count-1 {
                        passwd = row[idx]!
                        break
                    }
                }
                
                if passwd == password {
                    responseJson = Utils.failureResponseJson("新密码与原密码相同")
                } else {
                    let statement = "UPDATE \(accounttable) SET password = '\(password)' WHERE mobile = '\(mobile)'"
                    
                    if mysql.query(statement: statement) == false {
                        Utils.logError("重置密码", mysql.errorMessage())
                        responseJson = Utils.failureResponseJson("用户密码修改失败")
                    } else {
                        responseJson = Utils.successResponseJson("用户密码修改成功")
                    }
                }
            }
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("重置密码用户密码失败")
        }
        
        return responseJson
    }
    // MARK: - 更新用户信息
    ///
    /// - Parameters:
    ///   - params: 需要修改参数内容 userId（用户id）必填
    /// - Returns: 返回JSON数据
    func updateAccount(params: [String: Any]) -> String {
        let userId: String = params["userId"] as! String
        
        let accountStatus = checkAccount(mobile: "", nickname: "", userId: userId)
        if accountStatus == 1 {
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
                
                let statement = "UPDATE \(accounttable) SET \(contentValue.joined(separator: ", ")) WHERE userId = '\(userId)'"
                if mysql.query(statement: statement) == false {
                    Utils.logError("更新用户信息", mysql.errorMessage())
                    responseJson = Utils.failureResponseJson("更新用户信息失败")
                } else {
                    responseJson = self.getAccount(userId: userId, mobile: "", loginId: "")
                }
            }
            
            if params["nickname"] != nil {
                let nickname: String = params["nickname"] as! String
                if checkAccount(mobile: "", nickname: nickname, userId: "") == 1 {
                    responseJson = Utils.failureResponseJson("昵称已被占用")
                } else {
                    updateInfo()
                }
            } else {
                updateInfo()
            }
        } else if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("更新用户信息失败")
        }
        
        return responseJson
    }
    // MARK: - 用户粉丝列表 A(userId) 的粉丝列表 where userId==A
    func userFanListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        var keys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender"]
        
        var originalKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender"]
        
        var statements: [String] = []
        
        if loginId.count > 0 {
            keys.append("COUNT(DISTINCT fanAttentionTable.objectId) isAttention")
            originalKeys.append("isAttention")
            statements.append("LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(attentionfantable).authorId)")
            statements.append("LEFT JOIN \(attentionfantable) fanAttentionTable ON (fanAttentionTable.authorId = '\(loginId)' AND fanAttentionTable.userId = \(attentionfantable).authorId)")
        }
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(attentionfantable) \(statements.joined(separator: " ")) WHERE \(attentionfantable).userId = '\(userId)' GROUP BY \(attentionfantable).authorId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户粉丝列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户粉丝列表查询失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
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
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 用户关注列表 A 的关注列表 where authorId==A
    func userAttentionListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        var keys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender"]
        
        var originalKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender"]
        
        var statements: [String] = []
        
        if loginId.count > 0 {
            keys.append("COUNT(DISTINCT fanAttentionTable.objectId) isAttention")
            originalKeys.append("isAttention")
            statements.append("LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(attentionfantable).userId)")
            statements.append("LEFT JOIN \(attentionfantable) fanAttentionTable ON (fanAttentionTable.authorId = '\(loginId)' AND fanAttentionTable.userId = \(attentionfantable).userId)")
        }
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(attentionfantable) \(statements.joined(separator: " ")) WHERE \(attentionfantable).authorId = '\(userId)' GROUP BY \(attentionfantable).userId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户关注列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户关注列表查询失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
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
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 关注用户
    /// - Parameters:
    ///   - params: 参数内容 userId 被关注人 loginId 关注人
    /// - Returns: 返回JSON数据 状态 0 查询失败 不改变状态 1 已关注 2 未关注
    func accountAttention(params: [String: Any]) -> String {
        let tableName = attentionfantable
        
        let userId: String = params["userId"] as! String
        let loginId: String = params["loginId"] as! String
        
        // 状态 0 查询失败 不改变状态 1 已关注 2 未关注
        func checkIsAttention() -> Int {
            let statement = "SELECT COUNT(DISTINCT \(tableName).objectId) attentionCount FROM \(tableName) WHERE \(tableName).authorId = '\(loginId)' AND \(tableName).userId = '\(userId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("是否关注", mysql.errorMessage())
                return 0
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    var status: Int = 2
                    results.forEachRow { (row) in
                        for idx in 0...row.count-1 {
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
        
        if checkIsAttention() == 1 {
            // 取消关注
            let statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).userId = '\(userId)' AND \(tableName).authorId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("取消关注", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isSuccessful": false, "status": 0])
            } else {
                let status: Int = checkIsAttention()
                responseJson = Utils.successResponseJson(["isSuccessful": true, "status": status])
            }
        } else if checkIsAttention() == 2 {
            // 添加关注
            let statement = "INSERT INTO \(tableName) (authorId, userId) VALUES ('\(loginId)', '\(userId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("添加关注", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isSuccessful": false, "status": 0])
            } else {
                let status: Int = checkIsAttention()
                responseJson = Utils.successResponseJson(["isSuccessful": true, "status": status])
            }
        } else {
            responseJson = Utils.successResponseJson(["isSuccessful": false, "status": 0])
        }
        
        return responseJson
    }
}
