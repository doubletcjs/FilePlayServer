//
//  MovieOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/3/9.
//

import Foundation

class MovieOperator: DataBaseOperator {
    // MARK: - 电影详情是否存在
    ///
    /// - Parameters:
    ///   - movieId: 电影id
    /// - Returns: 0 不存在 1 已存在 2 查询失败
    private func checkMovieDetail(movieId: String) -> Int! {
        let statement = "SELECT movieId FROM \(movietable) WHERE \(movietable).movieId = '\(movieId)'"
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
    // MARK: - 电影详情
    ///
    /// - Parameters:
    ///   - loginId: 登录用户id
    ///   - movieId: 电影id
    /// - Returns: 返回JSON数据
    func getMovieDetail(loginId: String, movieId: String) -> String {
        let status = checkMovieDetail(movieId: movieId)
        if status == 1 {
            let originalKeys: [String] = [
                "movieId",
                "tmdbmovieId",
                "title",
                "original_title",
                "vote_average",
                "vote_count",
                "release_date",
                "poster_path",
                "genreids",
                "isEpisode",
                "wantCount",
                "watchCount",
                "dynamicCount",
                "isWant",
                "isWatch"]
            
            let keys: [String] = [
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
                "COUNT(DISTINCT \(wantmovietable).movieId) wantCount",
                "COUNT(DISTINCT \(watchmovietable).movieId) watchCount",
                "COUNT(DISTINCT \(dynamictable).objectId) dynamicCount",
                "COUNT(DISTINCT wantmovieTable.movieId) isWant",
                "COUNT(DISTINCT watchmovieTable.movieId) isWatch"]
            
            let statements: [String] = [
                "LEFT JOIN \(wantmovietable) ON (\(wantmovietable).movieId = '\(movieId)')",
                "LEFT JOIN \(watchmovietable) ON (\(watchmovietable).movieId = '\(movieId)')",
                "LEFT JOIN \(dynamictable) ON (\(dynamictable).movieId = '\(movieId)')",
                "LEFT JOIN \(wantmovietable) wantmovieTable ON (wantmovieTable.userId = '\(loginId)' AND wantmovieTable.movieId = '\(movieId)')",
                "LEFT JOIN \(watchmovietable) watchmovieTable ON (watchmovieTable.userId = '\(loginId)' AND watchmovieTable.movieId = '\(movieId)')"]
            
            let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(movietable) \(statements.joined(separator: " ")) WHERE \(movietable).movieId = '\(movieId)' GROUP BY \(movietable).movieId"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("电影详情", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("电影详情查询失败")
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
                    
                    if dict["isWant"] != nil {
                        if Int(dict["isWant"] as! String) != 0 {
                            dict["isWant"] = true
                        } else {
                            dict["isWant"] = false
                        }
                    }
                    
                    if dict["isWatch"] != nil {
                        if Int(dict["isWatch"] as! String) != 0 {
                            dict["isWatch"] = true
                        } else {
                            dict["isWatch"] = false
                        }
                    }
                    
                    dict["id"] = dict["tmdbmovieId"]
                    dict["tmdbmovieId"] = nil
                    
                    responseJson = Utils.successResponseJson(dict)
                } else {
                    responseJson = Utils.failureResponseJson("电影详情查询失败")
                }
            }
        } else if status == 2 {
            responseJson = Utils.failureResponseJson("电影详情查询失败")
        } else {
            responseJson = Utils.failureResponseJson("电影详情不存在")
        }
        
        return responseJson
    }
    // MARK: - 插入、更新电影详情
    ///
    /// - Parameters:
    ///   - params: 参数内容 loginId（登录用户id）必填 movie（TMDB电影数据）必填
    /// - Returns: 返回JSON数据
    func movieDetailHandle(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        
        let tmdbmovieId: String = params["tmdbmovieId"] as! String
        var movieId: String = params["movieId"] as! String
        let title: String = params["title"] as! String
        let original_title: String = params["original_title"] as! String
        let vote_average: String = params["vote_average"] as! String
        let vote_count: String = params["vote_count"] as! String
        let release_date: String = params["release_date"] as! String
        let poster_path: String = params["poster_path"] as! String
        let genreids: String = params["genreids"] as! String
        
        let episode: Int = Int(params["isEpisode"] as! String)!
        var isEpisode: Bool = false
        if episode != 0 {
            isEpisode = true
        }
        
        func checkTMDBMovieDetail(tmdbmovieId: String, isEpisode: Bool) -> Void {
            let statement = "SELECT movieId FROM \(movietable) WHERE \(movietable).tmdbmovieId = '\(tmdbmovieId)' AND \(movietable).isEpisode = \(isEpisode)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("电影详情是否存在", mysql.errorMessage())
            } else {
                let results = mysql.storeResults()!
                results.forEachRow { (row) in
                    movieId = row[0]! as String
                }
            }
        }
        
        checkTMDBMovieDetail(tmdbmovieId: tmdbmovieId, isEpisode: isEpisode)
        
        if movieId.count == 0 {
            let values = "('\(tmdbmovieId)', '\(Utils.fixSingleQuotes(title))', '\(Utils.fixSingleQuotes(original_title))', '\(vote_average)', '\(vote_count)', '\(release_date)', '\(poster_path)', '\(genreids)', \(isEpisode))"
            let statement = "INSERT INTO \(movietable) (tmdbmovieId, title, original_title, vote_average, vote_count, release_date, poster_path, genreids, isEpisode) VALUES \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("插入、更新电影详情", mysql.errorMessage())
                
                responseJson = Utils.failureResponseJson("插入、更新电影详情")
            } else {
                if mysql.query(statement: "select last_insert_id()") == false {
                    Utils.logError("获取电影详情id失败", mysql.errorMessage())
                    
                    responseJson = Utils.failureResponseJson("插入、更新电影详情失败")
                } else {
                    let results = mysql.storeResults()!
                    var movieId = ""
                    results.forEachRow { (row) in
                        for idx in 0...row.count-1 {
                            movieId = row[idx]!
                            break
                        }
                    }
                    
                    if movieId.count > 0 {
                        responseJson = getMovieDetail(loginId: loginId, movieId: movieId)
                    } else {
                        responseJson = Utils.failureResponseJson("插入、更新电影详情失败")
                    }
                }
            }
        } else {
            //已存在
            //数据库电影详情
            let originalKeys: [String] = [
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
            
            let keys: [String] = [
                "\(movietable).movieId",
                "\(movietable).tmdbmovieId",
                "\(movietable).title",
                "\(movietable).original_title",
                "\(movietable).vote_average",
                "\(movietable).vote_count",
                "\(movietable).release_date",
                "\(movietable).poster_path",
                "\(movietable).genreids",
                "\(movietable).isEpisode"]
            
            let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(movietable) WHERE \(movietable).movieId = '\(movieId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("数据库电影详情", mysql.errorMessage())
            } else {
                var conditions: [String] = []
                
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
                    
                    //比较
                    if tmdbmovieId != dict["tmdbmovieId"] as! String {
                        conditions.append("tmdbmovieId = '\(tmdbmovieId)'")
                    }
                    
                    if title != dict["title"] as! String {
                        conditions.append("title = '\(Utils.fixSingleQuotes(title))'")
                    }
                    
                    if original_title != dict["original_title"] as! String {
                        conditions.append("original_title = '\(Utils.fixSingleQuotes(original_title))'")
                    }
                    
                    if vote_average != dict["vote_average"] as! String {
                        conditions.append("vote_average = '\(vote_average)'")
                    }
                    
                    if vote_count != dict["vote_count"] as! String {
                        conditions.append("vote_count = '\(vote_count)'")
                    }
                    
                    if release_date != dict["release_date"] as! String {
                        conditions.append("release_date = '\(release_date)'")
                    }
                    
                    if poster_path != dict["poster_path"] as! String {
                        conditions.append("poster_path = '\(poster_path)'")
                    }
                    
                    if genreids != dict["genreids"] as! String {
                        conditions.append("genreids = '\(genreids)'")
                    }
                    
                    let episode: Int = Int(dict["isEpisode"] as! String)!
                    var tempIsEpisode: Bool = false
                    if episode != 0 {
                        tempIsEpisode = true
                    }
                    
                    if isEpisode != tempIsEpisode {
                        conditions.append("isEpisode = \(isEpisode)")
                    }
                }
                
                if conditions.count > 0 {
                    let statement = "UPDATE \(movietable) SET \(conditions.joined(separator: ", ")) WHERE \(movietable).movieId = '\(movieId)'"
                    
                    if mysql.query(statement: statement) == false {
                        Utils.logError("更新数据库电影详情", mysql.errorMessage())
                    }
                }
            }
            
            responseJson = getMovieDetail(loginId: loginId, movieId: movieId)
        }
        
        return responseJson
    }
    // MARK: - 想看
    func wantMovie(movieId: String, loginId: String) -> String {
        func isMovieWanted() -> Bool {
            let statement = "SELECT objectId FROM \(wantmovietable) WHERE \(wantmovietable).movieId = '\(movieId)' AND \(wantmovietable).userId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
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
        
        if isMovieWanted() == true {
            let statement = "DELETE \(wantmovietable) FROM \(wantmovietable) WHERE \(wantmovietable).movieId = '\(movieId)' AND \(wantmovietable).userId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("删除想看电影", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("操作失败")
            } else {
                responseJson = Utils.successResponseJson(["isSuccessful": true])
            }
        } else {
            let statement = "INSERT INTO \(wantmovietable) (movieId, userId) VALUES ('\(movieId)', '\(loginId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("想看电影", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("操作失败")
            } else {
                responseJson = Utils.successResponseJson(["isSuccessful": true])
            }
        }
        
        return responseJson
    }
    // MARK: - 想看、看过列表
    func wantWatchMovieList(params: [String: Any]) -> String {
        let userId: String = params["userId"] as! String
        let loginId: String = params["loginId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        let type: String = params["type"] as! String
        
        var tableName: String = wantmovietable
        var tip: String = "想看"
        
        if type == "watch" {
            tableName = watchmovietable
            tip = "看过"
        }
        
        let originalKeys: [String] = [
            "movieId",
            "tmdbmovieId",
            "title",
            "original_title",
            "vote_average",
            "vote_count",
            "release_date",
            "poster_path",
            "genreids",
            "isEpisode",
            "wantCount",
            "watchCount",
            "dynamicCount",
            "isWant",
            "isWatch"]
        
        let keys: [String] = [
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
            "COUNT(DISTINCT w_m.movieId) wantCount",
            "COUNT(DISTINCT w_c_n.movieId) watchCount",
            "COUNT(DISTINCT \(dynamictable).movieId) dynamicCount",
            "COUNT(DISTINCT wantmovieTable.movieId) isWant",
            "COUNT(DISTINCT watchmovieTable.movieId) isWatch"]
        
        let statements: [String] = [
            "LEFT JOIN \(movietable) ON (\(movietable).movieId = \(tableName).movieId)",
            "LEFT JOIN \(wantmovietable) w_m ON (w_m.movieId = \(movietable).movieId)",
            "LEFT JOIN \(watchmovietable) w_c_n ON (w_c_n.movieId = \(movietable).movieId)",
            "LEFT JOIN \(dynamictable) ON (\(dynamictable).movieId = \(movietable).movieId)",
            "LEFT JOIN \(wantmovietable) wantmovieTable ON (wantmovieTable.userId = '\(loginId)' AND wantmovieTable.movieId = \(movietable).movieId)",
            "LEFT JOIN \(watchmovietable) watchmovieTable ON (watchmovieTable.userId = '\(loginId)' AND watchmovieTable.movieId = \(movietable).movieId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(tableName) \(statements.joined(separator: " ")) WHERE \(tableName).userId = '\(userId)' GROUP BY \(movietable).movieId ORDER BY \(movietable).movieId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户\(tip)列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("查询失败")
        } else {
            var movieList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        let key = originalKeys[idx]
                        let value = row[idx]
                        dict[key] = value
                    }
                    
                    if dict["isWant"] != nil {
                        if Int(dict["isWant"] as! String) != 0 {
                            dict["isWant"] = true
                        } else {
                            dict["isWant"] = false
                        }
                    }
                    
                    if dict["isWatch"] != nil {
                        if Int(dict["isWatch"] as! String) != 0 {
                            dict["isWatch"] = true
                        } else {
                            dict["isWatch"] = false
                        }
                    }
                    
                    movieList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(movieList)
        }
        
        return responseJson
    }
    // MARK: - 看过
    func watchMovie(movieId: String, loginId: String) -> String {
        func isMovieWatched() -> Bool {
            let statement = "SELECT objectId FROM \(watchmovietable) WHERE \(watchmovietable).movieId = '\(movieId)' AND \(watchmovietable).userId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
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
        
        if isMovieWatched()  == true {
            let statement = "DELETE \(watchmovietable) FROM \(watchmovietable) WHERE \(watchmovietable).movieId = '\(movieId)' AND \(watchmovietable).userId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("删除看过电影", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("操作失败")
            } else {
                responseJson = Utils.successResponseJson(["isSuccessful": true])
            }
        } else {
            let statement = "INSERT INTO \(watchmovietable) (movieId, userId) VALUES ('\(movieId)', '\(loginId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("看过电影", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("操作失败")
            } else {
                responseJson = Utils.successResponseJson(["isSuccessful": true])
            }
        }
        
        return responseJson
    }
}
