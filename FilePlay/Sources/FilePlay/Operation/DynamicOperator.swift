//
//  DynamicOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/8/3.
//

import Foundation
import PerfectHTTP

class DynamicOperator: NSObject {
    // MARK: - 电影动态列表
    /**
     * params [String: Any]
     * 1. movieId 电影id
     * 2. loginId 登录用户id
     * 3. currentPage
     * 4. pageSize
     */
    func movieDynamicListHandle(request: HTTPRequest, response: HTTPResponse) {
        var loginId: String = ""
        var movieId: String = ""
        var currentPage: String = ""
        var pageSize: String = ""
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        }
        
        if request.param(name: "currentPage") != nil {
            currentPage = request.param(name: "currentPage")!
        }
        
        if request.param(name: "pageSize") != nil {
            pageSize = request.param(name: "pageSize")!
        }
        
        guard movieId.count > 0 && currentPage.count > 0 && pageSize.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        if Int(pageSize)! < 5 {
            pageSize = "5"
        }
        
        let responseJson = DynamicModel().movieDynamicListQuery(movieId: movieId, loginId: loginId, currentPage: Int(currentPage)!, pageSize: Int(pageSize)!)
        response.appendBody(string: responseJson)
        response.completed()
    }
}
