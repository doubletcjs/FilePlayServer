//
//  CommentOperator.swift
//  FilePlay
//
//  Created by 万烨 on 2019/5/9.
//

import Foundation

class CommentOperator: DataBaseOperator {
    // MARK: - 发布评论
    ///
    /// - Parameters:
    ///   - params: 参数内容 dynamicId（动态id） content（评论内容） replyId（回复对象） authorId（评论人）
    /// - Returns: 返回JSON数据
    func postCommentHandle(params: [String: Any]) -> String {
        let authorId: String = params["authorId"] as! String
        let content: String = params["content"] as! String
        let replyId: String = params["replyId"] as! String
        let dynamicId: String = params["dynamicId"] as! String
        
        let current = Date()
        let postDate = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
        
        let values = "('\(dynamicId)', '\(Utils.fixSingleQuotes(content))', '\(replyId)', '\(authorId)', '\(postDate)')"
        let statement = "INSERT INTO \(commenttable) (dynamicId, content, replyId, authorId, postDate) VALUES \(values)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("发布评论", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("发布评论失败")
        } else {
            responseJson = Utils.successResponseJson(["isSuccessful": true])
        }
        
        return responseJson
    }
    // MARK: - 动态评论列表
    ///
    /// - Parameters:
    ///   - params: 参数内容 loginId（用户id） dynamicId（动态id） currentPage pageSize
    /// - Returns: 返回JSON数据
    func dynamicCommentList(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        let dynamicId: String = params["dynamicId"] as! String
        
        let originalKeys: [String] = [
            "objectId",
            "dynamicId",
            "content",
            "postDate",
            "praiseCount",
            "reportCount",
            "isPraise"]
        
        // 评论人
        let authorValueOfKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender"];
        
        // 回复对象
        let replyValueOfKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender"];
        
        let keys: [String] = [
            "\(commenttable).objectId",
            "\(commenttable).dynamicId",
            "\(commenttable).content",
            "\(commenttable).postDate",
            "COUNT(DISTINCT \(reportcommenttable).commentId) reportCount",
            "COUNT(DISTINCT \(praisecommenttable).commentId) praiseCount",
            "COUNT(DISTINCT praisecommenttable.commentId) isPraise",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender",
            "replyaccounttable.userId",
            "replyaccounttable.nickname",
            "replyaccounttable.portrait",
            "replyaccounttable.gender"]
        
        let statements: [String] = [
            "LEFT JOIN \(reportcommenttable) ON (\(reportcommenttable).commentId = \(commenttable).objectId)",
            "LEFT JOIN \(praisecommenttable) ON (\(praisecommenttable).commentId = \(commenttable).objectId)",
            "LEFT JOIN \(praisecommenttable) praisecommenttable ON (praisecommenttable.authorId = '\(loginId)' AND praisecommenttable.commentId = \(commenttable).objectId)",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(commenttable).authorId)",
            "LEFT JOIN \(accounttable) replyaccounttable ON (replyaccounttable.userId = \(commenttable).replyId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(commenttable) \(statements.joined(separator: " ")) WHERE \(commenttable).dynamicId = '\(dynamicId)' GROUP BY \(commenttable).objectId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("动态评论列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("动态评论列表查询失败")
        } else {
            var commentList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    var author: [String: Any] = [:]
                    var reply: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        if idx < originalKeys.count {
                            let key = originalKeys[idx]
                            let value = row[idx]
                            dict[key] = value
                            
                            if dict["isPraise"] != nil {
                                if Int(dict["isPraise"] as! String) != 0 {
                                    dict["isPraise"] = true
                                } else {
                                    dict["isPraise"] = false
                                }
                            }
                        } else if idx < originalKeys.count+authorValueOfKeys.count {
                            let authorIdx: Int = idx-originalKeys.count
                            let key = authorValueOfKeys[authorIdx]
                            let value = row[idx]
                            author[key] = value
                        } else {
                            let replyIdx: Int = idx-(originalKeys.count+replyValueOfKeys.count)
                            let key = replyValueOfKeys[replyIdx]
                            let value = row[idx]
                            reply[key] = value
                        }
                    }
                    
                    if author.count > 0 {
                        dict["author"] = author
                    }
                    
                    if reply.count > 0 {
                        dict["reply"] = reply
                    }
                    
                    commentList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(commentList)
        }
        
        return responseJson
    }
}
