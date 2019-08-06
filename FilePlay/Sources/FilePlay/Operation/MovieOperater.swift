//
//  MovieOperater.swift
//  FilePlay
//
//  Created by 4work on 2019/8/6.
//

import Foundation
import PerfectHTTP

class MovieOperater: NSObject {
    // MARK: - 收藏、取消收藏
    /**
     * params [String: Any]
     * 1. userId 收藏人
     * 2. movieId 电影
     */
    func movieCollectionStatusHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var movieId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        }
        
        guard userId.count > 0 && movieId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = MovieModel().movieCollectionStatusQuery(userId: userId, movieId: movieId)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 已看
    /**
     * params [String: Any]
     * 1. userId 已看人
     * 2. movieId 电影
     */
    func movieWatchStatusHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var movieId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        }
        
        guard userId.count > 0 && movieId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = MovieModel().movieWatchStatusQuery(userId: userId, movieId: movieId)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 插入、更新电影详情
    /**
     * params [String: Any]
     * 1. loginId 必填
     */
    func updateMovieHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0..<params.count {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count > 1 || dict["loginId"] != nil else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = MovieModel().updateMovieQuery(params: dict)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 电影详情
    /**
     * params [String: Any]
     * 1. loginId 登录用户id
     * 2. movieId 电影id
     */
    func movieDetailHandle(request: HTTPRequest, response: HTTPResponse) {
        var loginId: String = ""
        var movieId: String = ""
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        }
        
        guard loginId.count > 0 && movieId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = MovieModel().movieDetailQuery(loginId: loginId, movieId: movieId)
        response.appendBody(string: responseJson)
        response.completed()
    }
}
