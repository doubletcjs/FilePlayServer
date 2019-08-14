//
//  TopicModel.swift
//  FilePlay
//
//  Created by 4work on 2019/8/3.
//

import Foundation

class TopicModel: DataBaseOperator {
    class func getAllPropertys() -> [String] {
        return [
            "topicId",
            "topicName",
            "createDate"];
    }
    
    /**
     *     话题id
     */
    @objc var topicId: String = ""
    /**
     *    话题名称
     */
    @objc var topicName: String = ""
    /**
     *    发布日期 yyyy-MM-dd HH:mm:ss
     */
    @objc var createDate: String = ""
    
    // MARK: - 话题是否存在
    ///
    /// - Parameters:
    ///   - topicName: 话题名称
    /// - Returns: 0 不存在 1 已存在 2 查询失败
    private func isTopicExist(topicName: String) -> Int! {
        let statement = "SELECT topicId FROM \(db_topic) WHERE \(db_topic).topicName = '\(Utils.fixSingleQuotes(topicName))'"
        if topicName.count == 0 {
            return 2
        }
        
        if mysql.query(statement: statement) == false {
            Utils.logError("话题是否存在", mysql.errorMessage())
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
    // MARK: - 创建话题
    /// - Parameters:
    ///   - topicName: 话题名称
    /// - Returns: 返回JSON数据
    func createTopicQuery(topicName: String) -> String {
        let state = isTopicExist(topicName: topicName)
        if state == 0 {
            let current = Date()
            let date = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
            
            let values = "('\(Utils.fixSingleQuotes(topicName))', '\(date)')"
            let statement = "INSERT INTO \(db_topic) (topicName, createDate) VALUES \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("创建话题", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("话题创建失败")
            } else {
                responseJson = self.topicDetailQuery(topicName: topicName)
            }
        } else if state == 1 {
            responseJson = self.topicDetailQuery(topicName: topicName)
        } else if state == 2 {
            responseJson = Utils.failureResponseJson("话题创建失败")
        }
        
        return responseJson
    }
    // MARK: - 话题详情
    ///
    /// - Parameters:
    ///   - topicName: 话题名称
    /// - Returns: 返回JSON数据
    private func topicDetailQuery(topicName: String) -> String {
        let state = isTopicExist(topicName: topicName)
        if state == 0 {
            responseJson = Utils.failureResponseJson("话题不存在")
        } else if state == 1 {
            var originalKeys: [String] = TopicModel.getAllPropertys()
            var tableKeys: [String] = []
            originalKeys.forEach { (key) in
                tableKeys.append("\(db_topic)."+key)
            }
            
            let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_topic) WHERE \(db_topic).topicName = '\(topicName)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("话题详情", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("话题详情查询失败")
            } else {
                let results = mysql.storeResults()
                var dict: [String: Any] = [:]
                results?.forEachRow { (row) in
                    for idx in 0..<row.count {
                        let key = originalKeys[idx]
                        dict["\(key)"] = row[idx]! as Any
                    }
                }
                
                responseJson = Utils.successResponseJson(dict)
            }
        } else {
            responseJson = Utils.failureResponseJson("话题详情查询失败")
        }
        
        return responseJson
    }
    // MARK: - 查询话题列表
    ///
    /// - Parameters:
    ///   - keyword: 查询条件
    ///   - currentPage: 当前页
    ///   - pageSize: pageSize
    /// - Returns: 动态列表
    func topicSearchListQuery(keyword: String, currentPage: Int, pageSize: Int) -> String {
        let originalKeys: [String] = TopicModel.getAllPropertys()
        var tableKeys: [String] = []
        originalKeys.forEach { (key) in
            tableKeys.append("\(db_topic)."+key)
        }
        
        let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_topic) WHERE \(db_topic).topicName LIKE '%\(keyword)%' GROUP BY \(db_topic).topicId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        if mysql.query(statement: statement) == false {
            Utils.logError("查询话题列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("话题查询失败")
        } else {
            var topicList = [[String: Any]]()
            let results = mysql.storeResults()
            
            results?.forEachRow { (row) in
                var dict: [String: Any] = [:]
                for idx in 0..<row.count {
                    let key = originalKeys[idx]
                    let value = row[idx]
                    dict[key] = value
                }
                //加入列表
                topicList.append(dict)
            }
            
            responseJson = Utils.successResponseJson(topicList)
        }
        
        return responseJson
    }
}
