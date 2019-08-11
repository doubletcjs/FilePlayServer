//
//  DynamicModel.swift
//  FilePlay
//
//  Created by 4work on 2019/8/3.
//

import Foundation

class DynamicModel: DataBaseOperator {
    class func getAllPropertys() -> [String] {
        return [
            "dynamicId",
            "content",
            "postDate",
            "imageUrls",
            "imageWH"];
    }
    
    // MARK: - 基本内容
    /**
     *     动态id
     */
    @objc var dynamicId: String = ""
    /**
     *     内容
     */
    @objc var content: String = ""
    /**
     *    发布日期 yyyy-MM-dd HH:mm:ss
     */
    @objc var postDate: String = ""
    /**
     *     图片列表 url1|url2
     */
    @objc var imageUrls: String = ""
    /**
     *     图片列表 w:h|w:h
     */
    @objc var imageWH: String = ""
/*
    // MARK: - 联表查询发布人信息
    /**
     *     发布人
     */
    @objc var authorId: String = ""
    // MARK: - 联表查询电影信息
    /**
     *     电影
     */
    @objc var movieId: String = ""
    // MARK: - 联表查询话题
    /**
     *     话题
     */
    @objc var topicId: String = ""
    // MARK: - 联表查询
    /**
     *     回复数
     */
    @objc var replyCount: Int = 0
    /**
     *     点赞数
     */
    @objc var likeCount: Int = 0
     /**
     *     是否点赞
     */
     @objc var isLike: Bool = false
*/
    
    // MARK: - 用户动态数
    ///
    /// - Parameters:
    ///   - userId: 用户id
    /// - Returns: 用户动态数
    func accountDynamicCountQuery(userId: String) -> Int {
        var count = 0
        let statement = "SELECT COUNT(DISTINCT \(db_dynamic).dynamicId) dynamicCount FROM \(db_dynamic) WHERE \(db_dynamic).authorId = '\(userId)'"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户动态数", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户动态数查询失败")
        } else {
            let results = mysql.storeResults()
            results?.forEachRow { (row) in
                for idx in 0..<row.count {
                    count = Int(row[idx]!)!
                    break
                }
            }
        }
        
        return count
    }
    // MARK: - 查询动态列表
    ///
    /// - Parameters:
    ///   - sql: 查询条件
    ///   - loginId: 当前登录用户id
    ///   - currentPage: 当前页
    ///   - pageSize: pageSize
    /// - Returns: 动态列表
    private func dynamicListQuery(sql: String, loginId: String, currentPage: Int, pageSize: Int) -> String {
        var originalKeys: [String] = DynamicModel.getAllPropertys()
        
        var tableKeys: [String] = [
            "\(db_dynamic).dynamicId",
            "\(db_dynamic).content",
            "\(db_dynamic).imageUrls",
            "\(db_dynamic).imageWH",
            "\(db_dynamic).postDate"]
        
        //点赞、回复数
        originalKeys.append("replyCount")
        originalKeys.append("likeCount")
        tableKeys.append("COUNT(DISTINCT \(db_comment).dynamicId) replyCount")
        tableKeys.append("COUNT(DISTINCT db_dynamic_praise.dynamicId) likeCount")
        
        var contingency: [String] = [
            "LEFT JOIN \(db_comment) ON (\(db_comment).dynamicId = \(db_dynamic).dynamicId)",
            "LEFT JOIN \(db_praise_dynamic) db_dynamic_praise ON (db_dynamic_praise.dynamicId = \(db_dynamic).dynamicId)"]
        
        //是否点赞
        originalKeys.append("isLike")
        tableKeys.append("COUNT(DISTINCT \(db_praise_dynamic).dynamicId) isLike")
        contingency.append("LEFT JOIN \(db_praise_dynamic) ON (\(db_praise_dynamic).authorId = '\(loginId)' AND \(db_praise_dynamic).dynamicId = \(db_dynamic).dynamicId)")
        
        //发布人
        originalKeys.append("userId")
        originalKeys.append("nickname")
        originalKeys.append("portrait")
        tableKeys.append("\(db_account).userId")
        tableKeys.append("\(db_account).nickname")
        tableKeys.append("\(db_account).portrait")
        contingency.append("LEFT JOIN \(db_account) ON (\(db_account).userId = \(db_dynamic).authorId)")
        
        //话题
        originalKeys.append("topicId")
        originalKeys.append("topicName")
        tableKeys.append("\(db_topic).topicId")
        tableKeys.append("\(db_topic).topicName")
        contingency.append("LEFT JOIN \(db_topic) ON (\(db_topic).topicId = \(db_dynamic).topicId)")
        
        //电影
        originalKeys.append("movieId")
        originalKeys.append("movieName")
        originalKeys.append("movieGenres")
        originalKeys.append("movieVoteAverage")
        originalKeys.append("moviePoster")
        tableKeys.append("\(db_movie).movieId")
        tableKeys.append("\(db_movie).movieName")
        tableKeys.append("\(db_movie).movieGenres")
        tableKeys.append("\(db_movie).movieVoteAverage")
        tableKeys.append("\(db_movie).moviePoster")
        contingency.append("LEFT JOIN \(db_movie) ON (\(db_movie).movieId = \(db_dynamic).movieId)")
        
        let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_dynamic) \(contingency.joined(separator: " ")) \(sql) GROUP BY \(db_dynamic).dynamicId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户动态列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户动态列表查询失败")
        } else {
            let baseEndIndex = 7
            let authorEndIndex = baseEndIndex+3
            let topicEndIndex = authorEndIndex+2
            
            var dynamicList = [[String: Any]]()
            let results = mysql.storeResults()
            results?.forEachRow { (row) in
                var dict: [String: Any] = [:]
                var author: [String: Any] = [:]
                var topic: [String: Any] = [:]
                var movie: [String: Any] = [:]
                
                for idx in 0..<row.count {
                    let key = originalKeys[idx]
                    let value = row[idx]
                    
                    if idx <= baseEndIndex {
                        dict[key] = value
                        //基本信息
                        if dict["isLike"] != nil {
                            if Int(dict["isLike"] as! String) != 0 {
                                dict["isLike"] = true
                            } else {
                                dict["isLike"] = false
                            }
                        }
                    } else if idx <= authorEndIndex {
                        //发布人
                        author[key] = value
                    } else if idx <= topicEndIndex {
                        //话题
                        topic[key] = value
                    } else {
                        //电影
                        movie[key] = value
                    }
                }
                
                dict["author"] = author
                dict["topic"] = topic
                dict["movie"] = movie
                //加入列表
                dynamicList.append(dict)
            }
            
            responseJson = Utils.successResponseJson(dynamicList)
        }
        
        return responseJson
    }
    // MARK: - 用户动态列表
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - loginId: 当前登录用户id
    ///   - currentPage: 当前页
    ///   - pageSize: pageSize
    /// - Returns: 用户动态列表
    func accountDynamicListQuery(userId: String, loginId: String, currentPage: Int, pageSize: Int) -> String {
        return self.dynamicListQuery(sql: "WHERE \(db_dynamic).authorId = '\(userId)'", loginId: loginId, currentPage: currentPage, pageSize: pageSize)
    }
    // MARK: - 电影动态列表
    ///
    /// - Parameters:
    ///   - movieId: 电影id
    ///   - loginId: 当前登录用户id
    ///   - currentPage: 当前页
    ///   - pageSize: pageSize
    /// - Returns: 电影动态列表
    func movieDynamicListQuery(movieId: String, loginId: String, currentPage: Int, pageSize: Int) -> String {
        return self.dynamicListQuery(sql: "WHERE \(db_dynamic).movieId = '\(movieId)'", loginId: loginId, currentPage: currentPage, pageSize: pageSize)
    }
}
