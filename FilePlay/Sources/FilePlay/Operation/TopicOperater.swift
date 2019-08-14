//
//  TopicOperater.swift
//  FilePlay
//
//  Created by 万烨 on 2019/8/14.
//

import Foundation
import PerfectHTTP

class TopicOperater: NSObject {
    // MARK: - 创建话题
    /**
     * params [String: Any]
     * 1. topicName 登录用户id
     */
    func createTopicHandle(request: HTTPRequest, response: HTTPResponse) {
        var topicName: String = ""
        
        if request.param(name: "topicName") != nil {
            topicName = request.param(name: "topicName")!
        }
        
        guard topicName.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let responseJson = TopicModel().createTopicQuery(topicName: topicName)
        response.appendBody(string: responseJson)
        response.completed()
    }
    // MARK: - 查询话题列表
    /**
     * params [String: Any]
     * 1. keyword 查询条件
     * 2. currentPage
     * 3. pageSize
     */
    func topicSearchListHandle(request: HTTPRequest, response: HTTPResponse) {
        var keyword: String = ""
        var currentPage: String = ""
        var pageSize: String = ""
        
        if request.param(name: "keyword") != nil {
            keyword = request.param(name: "keyword")!
        }
        
        if request.param(name: "currentPage") != nil {
            currentPage = request.param(name: "currentPage")!
        }
        
        if request.param(name: "pageSize") != nil {
            pageSize = request.param(name: "pageSize")!
        }
        
        guard keyword.count > 0 && currentPage.count > 0 && pageSize.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        if Int(pageSize)! < 5 {
            pageSize = "5"
        }
        
        let responseJson = TopicModel().topicSearchListQuery(keyword: keyword, currentPage: Int(currentPage)!, pageSize: Int(pageSize)!)
        response.appendBody(string: responseJson)
        response.completed()
    }
}
