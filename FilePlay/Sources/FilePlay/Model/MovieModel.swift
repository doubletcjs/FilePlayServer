//
//  MovieModel.swift
//  FilePlay
//
//  Created by 万烨 on 2019/8/3.
//

import Foundation

class MovieModel: DataBaseOperator {
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
}
