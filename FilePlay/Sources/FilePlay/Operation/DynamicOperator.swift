//
//  DynamicOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/3/11.
//

import Foundation

class DynamicOperator: DataBaseOperator {
    // MARK: - 发布动态
    ///
    /// - Parameters:
    ///   - params: 参数内容 authorId（用户id） movieId（TMDB电影id） content（动态内容） image（图片url，url|url） imageWH（图片宽高，宽:高|宽:高）
    /// - Returns: 返回JSON数据
    func postDynamicHandle(params: [String: Any]) -> String {
        let authorId: String = params["authorId"] as! String
        let movieId: String = params["movieId"] as! String
        let content: String = params["content"] as! String
        var image: String? = ""
        if params["image"] != nil {
            image = params["image"] as? String
        }
        
        var imageWH: String? = ""
        if params["imageWH"] != nil {
            imageWH = params["imageWH"] as? String
        }
        
        let current = Date()
        let postDate = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
        
        let values = "('\(authorId)', '\(movieId)', '\(Utils.fixSingleQuotes(content))', '\(image!)', '\(imageWH!)', '\(postDate)')"
        let statement = "INSERT INTO \(dynamictable) (authorId, movieId, content, image, imageWH, postDate) VALUES \(values)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("发布动态", mysql.errorMessage())
        } else {
            responseJson = Utils.successResponseJson(["isSuccessful": true])
        }
        
        return responseJson
    }
    // MARK: - 用户动态列表
    ///
    /// - Parameters:
    ///   - params: 参数内容 loginId（用户id） userId（用户id）currentPage pageSize
    /// - Returns: 返回JSON数据
    func accountDynamicList(params: [String: Any]) -> String {
        let userId: String = params["userId"] as! String
        let loginId: String = params["loginId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        let keys: [String] = [
            "\(dynamictable).objectId",
            "\(dynamictable).content",
            "\(dynamictable).image",
            "\(dynamictable).imageWH",
            "\(dynamictable).postDate",
            "COUNT(DISTINCT \(reportdynamictable).dynamicId) reportCount",
            "COUNT(DISTINCT \(praisedynamictable).dynamicId) praiseCount",
            "COUNT(DISTINCT \(commenttable).dynamicId) commentCount",
            "COUNT(DISTINCT praisedynamictable.dynamicId) isPraise",
            "\(movietable).movieId",
            "\(movietable).tmdbmovieId",
            "\(movietable).title",
            "\(movietable).original_title",
            "\(movietable).vote_average",
            "\(movietable).vote_count",
            "\(movietable).release_date",
            "\(movietable).poster_path",
            "\(movietable).genreids",
            "\(movietable).isEpisode",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender"]
        
        let originalKeys: [String] = [
            "objectId",
            "content",
            "image",
            "imageWH",
            "postDate",
            "reportCount",
            "praiseCount",
            "commentCount",
            "isPraise"]
        
        let movieValueOfKeys: [String] = [
            "movieId",
            "tmdbmovieId",
            "title",
            "original_title",
            "vote_average",
            "vote_count",
            "release_date",
            "poster_path",
            "genreids",
            "isEpisode"]
        
        let accountValueOfKeys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender"];
        
        let statements: [String] = [
            "LEFT JOIN \(reportdynamictable) ON (\(reportdynamictable).dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(praisedynamictable) ON (\(praisedynamictable).dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(praisedynamictable) praisedynamictable ON (praisedynamictable.authorId = '\(loginId)' AND praisedynamictable.dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(movietable) ON (\(movietable).movieId = \(dynamictable).movieId)",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(dynamictable).authorId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(dynamictable) \(statements.joined(separator: " ")) WHERE \(dynamictable).authorId = '\(userId)' GROUP BY \(dynamictable).objectId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户动态列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户动态列表查询失败")
        } else {
            var dynamicList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    var movie: [String: Any] = [:]
                    var author: [String: Any] = [:]
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
                        } else if idx < originalKeys.count+movieValueOfKeys.count {
                            let movieIdx: Int = idx-originalKeys.count
                            let key = movieValueOfKeys[movieIdx]
                            let value = row[idx]
                            movie[key] = value
                        } else {
                            let accountIdx: Int = idx-(originalKeys.count+movieValueOfKeys.count)
                            let key = accountValueOfKeys[accountIdx]
                            let value = row[idx]
                            author[key.replacingOccurrences(of: "\(accounttable).", with: "")] = value
                        }
                    }
                    
                    if movie.count > 0 {
                        movie["id"] = movie["tmdbmovieId"]
                        movie["tmdbmovieId"] = nil
                        dict["movie"] = movie
                    }
                    
                    if author.count > 0 {
                        dict["author"] = author
                    }
                    
                    dynamicList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(dynamicList)
        }
        
        return responseJson
    }
    // MARK: - 动态列表
    ///
    /// - Parameters:
    ///   - params: 参数内容 loginId（用户id） movieId（movieId） currentPage pageSize
    /// - Returns: 返回JSON数据
    func dynamicList(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        let movieId: String = params["movieId"] as! String
        
        let originalKeys: [String] = [
            "objectId",
            "content",
            "image",
            "imageWH",
            "postDate",
            "reportCount",
            "praiseCount",
            "commentCount",
            "isPraise"]
        
        let accountValueOfKeys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender"];
        
        let keys: [String] = [
            "\(dynamictable).objectId",
            "\(dynamictable).content",
            "\(dynamictable).image",
            "\(dynamictable).imageWH",
            "\(dynamictable).postDate",
            "COUNT(DISTINCT \(reportdynamictable).dynamicId) reportCount",
            "COUNT(DISTINCT \(praisedynamictable).dynamicId) praiseCount",
            "COUNT(DISTINCT \(commenttable).dynamicId) commentCount",
            "COUNT(DISTINCT praisedynamictable.dynamicId) isPraise",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender"]
        
        let statements: [String] = [
            "LEFT JOIN \(reportdynamictable) ON (\(reportdynamictable).dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(praisedynamictable) ON (\(praisedynamictable).dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(praisedynamictable) praisedynamictable ON (praisedynamictable.authorId = '\(loginId)' AND praisedynamictable.dynamicId = \(dynamictable).objectId)",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(dynamictable).authorId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(dynamictable) \(statements.joined(separator: " ")) WHERE \(dynamictable).movieId = '\(movieId)' GROUP BY \(dynamictable).objectId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("动态列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("动态列表查询失败")
        } else {
            var dynamicList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    var author: [String: Any] = [:]
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
                        } else {
                            let accountIdx: Int = idx-originalKeys.count
                            let key = accountValueOfKeys[accountIdx]
                            let value = row[idx]
                            author[key.replacingOccurrences(of: "\(accounttable).", with: "")] = value
                        }
                    }
                    
                    if author.count > 0 {
                        dict["author"] = author
                    }
                    
                    dynamicList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(dynamicList)
        }
        
        return responseJson
    }
    // MARK: - 动态点赞
    ///
    /// - Parameters:
    ///   - dynamicId: 动态id
    ///   - authorId: 点赞人
    /// - Returns: 返回JSON数据
    func dynamiPraiseHandle(dynamicId: String, authorId: String) -> String {
        func checkIsPraise() -> Bool {
            let statement = "SELECT objectId FROM \(praisedynamictable) WHERE \(praisedynamictable).dynamicId = '\(dynamicId)' AND \(praisedynamictable).authorId = '\(authorId)'"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("动态点赞查询", mysql.errorMessage())
                return false
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    return true
                } else {
                    return false
                }
            }
        }
        
        if checkIsPraise() == true {
            let statement = "DELETE \(praisedynamictable) FROM \(praisedynamictable) WHERE \(praisedynamictable).dynamicId = '\(dynamicId)' AND \(praisedynamictable).authorId = '\(authorId)'"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("动态取消点赞", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isPraise": false, "isSuccessful": false])
            } else {
                responseJson = Utils.successResponseJson(["isPraise": false, "isSuccessful": true])
            }
        } else {
            let statement = "INSERT INTO \(praisedynamictable) (dynamicId, authorId) VALUES ('\(dynamicId)', '\(authorId)')"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("动态点赞", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isPraise": false, "isSuccessful": false])
            } else {
                responseJson = Utils.successResponseJson(["isPraise": true, "isSuccessful": true])
            }
        }
        
        return responseJson
    }
}
