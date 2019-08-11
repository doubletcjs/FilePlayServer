//
//  MovieModel.swift
//  FilePlay
//
//  Created by 4work on 2019/8/3.
//

import Foundation

class MovieModel: DataBaseOperator {
    class func getAllPropertys() -> [String] {
        return [
            "movieId",
            "movieName",
            "movieGenres",
            "movieVoteAverage",
            "movieVoteCount",
            "movieReleaseDate",
            "movieOriginalName",
            "moviePoster",
            "movieHybridId",
            "movieRuntime"];
    }
    
    /**
     *     电影id
     */
    @objc var movieId: String = ""
    /**
     *    电影名
     */
    @objc var movieName: String = ""
    /**
     *    类型
     */
    @objc var movieGenres: String = ""
    /**
     *    评分
     */
    @objc var movieVoteAverage: String = ""
    /**
     *    评分人数
     */
    @objc var movieVoteCount: String = ""
    /**
     *    上映日期
     */
    @objc var movieReleaseDate: String = ""
    /**
     *    产地电影名
     */
    @objc var movieOriginalName: String = ""
    /**
     *    电影海报
     */
    @objc var moviePoster: String = ""
    /**
     *     电影混合id 前缀 0_ 电影 1_ 剧集 + tmdbid
     */
    @objc var movieHybridId: String = ""
    /**
     *    电影时长
     */
    @objc var movieRuntime: String = ""
/*
    // MARK: - 联表查询
    /**
     *     是否已看
     */
    @objc var isWatched: Bool = false
    /**
     *     收藏数
     */
    @objc var collectionCount: Int = 0
    /**
     *     是否已收藏
     */
    @objc var isCollection: Bool = false
*/
    
    // MARK: - 电影详情是否存在
    ///
    /// - Parameters:
    ///   - movieId: 电影id
    /// - Returns: 0 不存在 1 已存在 2 查询失败
    private func isMovieExist(movieId: String) -> Int! {
        let statement = "SELECT movieId FROM \(db_movie) WHERE \(db_movie).movieId = '\(movieId)'"
        if movieId.count == 0 {
            return 2
        }
        
        if mysql.query(statement: statement) == false {
            Utils.logError("电影详情是否存在", mysql.errorMessage())
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
    // MARK: - 收藏影片总数
    ///
    /// - Parameters:
    ///   - userId: 用户id
    /// - Returns: 用户动态数
    func accountCollectionCountQuery(userId: String) -> Int {
        var count = 0
        let statement = "SELECT COUNT(DISTINCT \(db_collection_movie).movieId) movieCount FROM \(db_collection_movie) WHERE \(db_collection_movie).userId = '\(userId)'"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("收藏影片总数", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("收藏影片总数查询失败")
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
    // MARK: - 用户电影收藏列表
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - loginId: 当前登录用户id
    ///   - currentPage: 当前页
    ///   - pageSize: pageSize
    /// - Returns: 用户动态数
    func accountCollectionListQuery(userId: String, loginId: String, currentPage: Int, pageSize: Int) -> String {
        var originalKeys: [String] = MovieModel.getAllPropertys()
        originalKeys.append("isCollection")
        
        let tableKeys: [String] = [
            "\(db_movie).movieId",
            "\(db_movie).movieName",
            "\(db_movie).movieGenres",
            "\(db_movie).movieVoteAverage",
            "\(db_movie).movieVoteCount",
            "\(db_movie).movieReleaseDate",
            "\(db_movie).movieOriginalName",
            "\(db_movie).moviePoster",
            "\(db_movie).movieRuntime",
            "COUNT(DISTINCT db_movie_collection.movieId) isCollection"]
        
        let contingency: [String] = [
            "LEFT JOIN \(db_movie) ON (\(db_movie).movieId = \(db_collection_movie).movieId)",
            "LEFT JOIN \(db_collection_movie) db_movie_collection ON (db_movie_collection.userId = '\(loginId)' AND db_movie_collection.movieId = \(db_movie).movieId)"]
        
        let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_collection_movie) \(contingency.joined(separator: " ")) WHERE \(db_collection_movie).userId = '\(userId)' GROUP BY \(db_collection_movie).objectId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户电影收藏列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户电影收藏列表查询失败")
        } else {
            var collectionList = [[String: Any]]()
            let results = mysql.storeResults()
            results?.forEachRow { (row) in
                var dict: [String: Any] = [:]
                for idx in 0..<row.count {
                    let key = originalKeys[idx]
                    let value = row[idx]
                    dict[key] = value
                    
                    if dict["isCollection"] != nil {
                        if Int(dict["isCollection"] as! String) != 0 {
                            dict["isCollection"] = true
                        } else {
                            dict["isCollection"] = false
                        }
                    }
                }
                
                //加入列表
                collectionList.append(dict)
            }
            
            responseJson = Utils.successResponseJson(collectionList)
        }
        
        return responseJson
    }
    // MARK: - 收藏、取消收藏
    /// - Parameters:
    ///   - userId: 收藏人
    ///   - movieId: 电影
    /// - Returns: 返回JSON数据 状态 0 查询失败 不改变状态 1 已收藏 2 未收藏
    func movieCollectionStatusQuery(userId: String, movieId: String) -> String {
        let tableName = db_collection_movie
        // 状态 0 查询失败 不改变状态 1 已收藏 2 未收藏
        func isCollection() -> Int {
            let statement = "SELECT COUNT(DISTINCT \(tableName).objectId) collectionCount FROM \(tableName) WHERE \(tableName).movieId = '\(movieId)' AND \(tableName).userId = '\(userId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("是否收藏电影", mysql.errorMessage())
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
        
        if isCollection() == 1 {
            // 取消收藏
            let statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).userId = '\(userId)' AND \(tableName).movieId = '\(movieId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("取消收藏", mysql.errorMessage())
                responseJson = Utils.successResponseJson("0")
            } else {
                responseJson = Utils.successResponseJson("\(isCollection())")
            }
        } else if isCollection() == 2 {
            // 添加收藏
            let statement = "INSERT INTO \(tableName) (movieId, userId) VALUES ('\(movieId)', '\(userId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("添加收藏", mysql.errorMessage())
                responseJson = Utils.successResponseJson("0")
            } else {
                responseJson = Utils.successResponseJson("\(isCollection())")
            }
        } else {
            responseJson = Utils.successResponseJson("0")
        }
        
        return responseJson
    }
    // MARK: - 已看、未看
    /// - Parameters:
    ///   - userId: 已看人
    ///   - movieId: 电影
    /// - Returns: 返回JSON数据 状态 0 查询失败 不改变状态 1 已看 2 未看
    func movieWatchStatusQuery(userId: String, movieId: String) -> String {
        let tableName = db_watch_movie
        // 状态 0 查询失败 不改变状态 1 已看 2 未看
        func isCollection() -> Int {
            let statement = "SELECT COUNT(DISTINCT \(tableName).objectId) collectionCount FROM \(tableName) WHERE \(tableName).movieId = '\(movieId)' AND \(tableName).userId = '\(userId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("是否已看电影", mysql.errorMessage())
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
        
        if isCollection() == 1 {
            // 取消已看
            let statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).userId = '\(userId)' AND \(tableName).movieId = '\(movieId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("取消已看", mysql.errorMessage())
                responseJson = Utils.successResponseJson("0")
            } else {
                responseJson = Utils.successResponseJson("\(isCollection())")
            }
        } else if isCollection() == 2 {
            // 添加已看
            let statement = "INSERT INTO \(tableName) (movieId, userId) VALUES ('\(movieId)', '\(userId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("添加已看", mysql.errorMessage())
                responseJson = Utils.successResponseJson("0")
            } else {
                responseJson = Utils.successResponseJson("\(isCollection())")
            }
        } else {
            responseJson = Utils.successResponseJson("0")
        }
        
        return responseJson
    }
    // MARK: - 插入、更新电影详情
    /**
     * params [String: Any]
     * 1. loginId 必填
     */
    ///
    /// - Parameters:
    ///   - params: [String: Any]
    /// - Returns: 电影详情
    func updateMovieQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        
        let model = MovieModel()
        model.movieName = params["movieName"] as! String
        model.movieOriginalName = params["movieOriginalName"] as! String
        model.movieGenres = params["movieGenres"] as! String
        model.movieVoteAverage = params["movieVoteAverage"] as! String
        model.movieVoteCount = params["movieVoteCount"] as! String
        model.movieReleaseDate = params["movieReleaseDate"] as! String
        model.moviePoster = params["moviePoster"] as! String
        model.movieHybridId = params["movieHybridId"] as! String
        model.movieRuntime = params["movieRuntime"] as! String
        
        var tempMovieId = ""
        func movieExist() -> Void {
            let statement = "SELECT movieId FROM \(db_movie) WHERE \(db_movie).movieHybridId = '\(model.movieHybridId)'"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("电影是否存在", mysql.errorMessage())
            } else {
                let results = mysql.storeResults()!
                results.forEachRow { (row) in
                    tempMovieId = row[0]! as String
                }
            }
        }
        
        //是否已存在
        movieExist()
        if tempMovieId.count == 0 {
            //不存在
            let values = "('\(Utils.fixSingleQuotes(model.movieName))', '\(model.movieGenres)', '\(model.movieVoteAverage)', '\(model.movieVoteCount)', '\(model.movieReleaseDate)', '\(Utils.fixSingleQuotes(model.movieOriginalName))', '\(model.moviePoster)', '\(model.movieHybridId)', '\(model.movieRuntime)')"
            let statement = "INSERT INTO \(db_movie) (movieName, movieGenres, movieVoteAverage, movieVoteCount, movieReleaseDate, movieOriginalName, moviePoster, movieHybridId, movieRuntime) VALUES \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("插入电影详情", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("插入电影详情")
            } else {
                movieExist()
                if tempMovieId.count > 0 {
                    responseJson = self.movieDetailQuery(loginId: loginId, movieId: tempMovieId)
                } else {
                    responseJson = Utils.failureResponseJson("插入电影详情失败")
                }
            }
        } else {
            //已存在
            let originalKeys: [String] = MovieModel.getAllPropertys()
            var tableKeys: [String] = []
            originalKeys.forEach { (key) in
                tableKeys.append("\(db_movie)."+key)
            }
            
            let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_movie) WHERE \(db_movie).movieId = '\(tempMovieId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("更新电影详情", mysql.errorMessage())
            } else {
                var conditions: [String] = []
                let results = mysql.storeResults()
                
                var dict: [String: Any] = [:]
                results?.forEachRow { (row) in
                    for idx in 0..<row.count {
                        let key = originalKeys[idx]
                        dict["\(key)"] = row[idx]! as Any
                    }
                }
                
                //比较
                if model.movieName != dict["movieName"] as! String {
                    conditions.append("movieName = '\(Utils.fixSingleQuotes(model.movieName))'")
                }
                
                if model.movieOriginalName != dict["movieOriginalName"] as! String {
                    conditions.append("movieOriginalName = '\(Utils.fixSingleQuotes(model.movieOriginalName))'")
                }
                
                if model.movieGenres != dict["movieGenres"] as! String {
                    conditions.append("movieGenres = '\(model.movieGenres)'")
                }
                
                if model.movieVoteAverage != dict["movieVoteAverage"] as! String {
                    conditions.append("movieVoteAverage = '\(model.movieVoteAverage)'")
                }
                
                if model.movieVoteCount != dict["movieVoteCount"] as! String {
                    conditions.append("movieVoteCount = '\(model.movieVoteCount)'")
                }
                
                if model.movieReleaseDate != dict["movieReleaseDate"] as! String {
                    conditions.append("movieReleaseDate = '\(model.movieReleaseDate)'")
                }
                
                if model.moviePoster != dict["moviePoster"] as! String {
                    conditions.append("moviePoster = '\(model.moviePoster)'")
                }
                
                if model.movieHybridId != dict["movieHybridId"] as! String {
                    conditions.append("movieHybridId = '\(model.movieHybridId)'")
                }
                
                if model.movieRuntime != dict["movieRuntime"] as! String {
                    conditions.append("movieRuntime = '\(model.movieRuntime)'")
                }
                
                if conditions.count > 0 {
                    let statement = "UPDATE \(db_movie) SET \(conditions.joined(separator: ", ")) WHERE \(db_movie).movieId = '\(tempMovieId)'"
                    if mysql.query(statement: statement) == false {
                        Utils.logError("更新电影详情", mysql.errorMessage())
                    }
                }
            }
            
            responseJson = self.movieDetailQuery(loginId: loginId, movieId: tempMovieId)
        }
        
        return responseJson
    }
    // MARK: - 电影详情
    ///
    /// - Parameters:
    ///   - loginId: 登录用户id
    ///   - movieId: 电影id
    /// - Returns: 返回JSON数据
    func movieDetailQuery(loginId: String, movieId: String) -> String {
        let status = isMovieExist(movieId: movieId)
        if status == 0 {
            responseJson = Utils.failureResponseJson("电影详情不存在")
        } else if status == 1 {
            var originalKeys: [String] = MovieModel.getAllPropertys()
            var tableKeys: [String] = []
            originalKeys.forEach { (key) in
                tableKeys.append("\(db_movie)."+key)
            }
            
            originalKeys.append("isWatched")
            originalKeys.append("isCollection")
            originalKeys.append("collectionCount")
            
            tableKeys.append("COUNT(DISTINCT db_watch_movie_count.movieId) isWatched")
            tableKeys.append("COUNT(DISTINCT db_collection_movie_count.movieId) isCollection")
            tableKeys.append("COUNT(DISTINCT \(db_collection_movie).movieId) collectionCount")
            
            let statements: [String] = [
                "LEFT JOIN \(db_watch_movie) db_watch_movie_count ON (db_watch_movie_count.userId = '\(loginId)' AND db_watch_movie_count.movieId = '\(movieId)')",
                "LEFT JOIN \(db_collection_movie) db_collection_movie_count ON (db_collection_movie_count.userId = '\(loginId)' AND db_collection_movie_count.movieId = '\(movieId)')",
                "LEFT JOIN \(db_collection_movie) ON (\(db_collection_movie).movieId = '\(movieId)')"]
            
            let statement = "SELECT \(tableKeys.joined(separator: ", ")) FROM \(db_movie) \(statements.joined(separator: " ")) WHERE \(db_movie).movieId = '\(movieId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("电影详情", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("电影详情查询失败")
            } else {
                let results = mysql.storeResults()
                var dict: [String: Any] = [:]
                results?.forEachRow { (row) in
                    for idx in 0..<row.count {
                        let key = originalKeys[idx]
                        dict["\(key)"] = row[idx]! as Any
                    }
                }
                
                if dict["isWatched"] != nil {
                    if Int(dict["isWatched"] as! String) != 0 {
                        dict["isWatched"] = true
                    } else {
                        dict["isWatched"] = false
                    }
                }
                
                if dict["isCollection"] != nil {
                    if Int(dict["isCollection"] as! String) != 0 {
                        dict["isCollection"] = true
                    } else {
                        dict["isCollection"] = false
                    }
                }
                
                responseJson = Utils.successResponseJson(dict)
            }
        } else {
            responseJson = Utils.failureResponseJson("电影详情查询失败")
        }
        
        return responseJson
    }
}
