//
//  ApiOperation.swift
//  FilePlay
//
//  Created by 4work on 2019/3/8.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// localhost html
private let LocalhostHtml: String = "<html><meta charset=\"UTF-8\"><title>Api Server</title><body>接口服务器<br>V0.0.1</body></html>"

class BasicRoutes {
    var routes: Routes {
        get {
            var baseRoutes = Routes()
            
            // localhost
            
            // Configure one server which:
            //    * Serves the hello world message at <host>:<port>/
            //    * Serves static files out of the "./webroot"
            //        directory (which must be located in the current working directory).
            //    * Performs content compression on outgoing data when appropriate.
            
            baseRoutes.add(method: .get, uri: "/", handler: localhostHandler)
            baseRoutes.add(method: .get, uri: "/**", handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)
            
            // 文件上传
            baseRoutes.add(method: .post, uri: "/fileUpload", handler: baseFileUploadHandle)
            
            // 注册
            baseRoutes.add(method: .post, uri: "/register", handler: registerHandle)
            // 手机号密码登录
            baseRoutes.add(method: .post, uri: "/login", handler: loginHandle)
            // 修改密码
            baseRoutes.add(method: .post, uri: "/resetPasswd", handler: resetPasswordHandle)
            // 用户信息
            baseRoutes.add(method: .post, uri: "/accountInfo", handler: accountInfoHandle)
            // 更新用户信息
            baseRoutes.add(method: .post, uri: "/updateAccount", handler: updateAccountHandle)
            
            return baseRoutes
        }
    }
    // MARK: - localhost
    private func localhostHandler(request: HTTPRequest, response: HTTPResponse) {
        // Respond with a simple message.
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: LocalhostHtml)
        // Ensure that response.completed() is called when your processing is done.
        response.completed()
    }
    // MARK: - 文件上传基础方法 function: portrait dynamic
    private func baseFileUploadHandle(_ request: HTTPRequest, _ response: HTTPResponse) {
        do {
            var function: String = ""
            if request.param(name: "function") != nil {
                function = request.param(name: "function")!
            }
            
            guard function.count > 0 else {
                response.setBody(string: Utils.failureResponseJson("上传参数错误"))
                response.completed()
                
                return
            }
            
            guard let uploads = request.postFileUploads, uploads.count > 0 else {
                try response.setBody(json: Utils.failureResponseJson("上传参数错误"))
                response.completed()
                return
            }
            
            //设置、创建文件存储目录
            var fileDir = Dir(server.documentRoot + "/files" + "/\(function)")
            if function == "portrait" {
                var userId: String = ""
                
                if request.param(name: "userId") != nil {
                    userId = request.param(name: "userId")!
                }
                
                guard userId.count > 0 else {
                    response.setBody(string: Utils.failureResponseJson("上传参数错误"))
                    response.completed()
                    
                    return
                }
                
                fileDir = Dir(server.documentRoot + "/files" + "/\(function)" + "/\(userId)")
            }
            
            do {
                try fileDir.create()
            } catch {
                print("\(error)")
                try response.setBody(json: Utils.failureResponseJson("无法创建功能类文件夹"))
                response.completed()
                return
            }
            
            if let uploads = request.postFileUploads, uploads.count > 0 {
                var pathArray = [String]()
                for upload in uploads {
                    //文件信息
                    /*
                     var array = [[String: Any]]()
                     array.append([
                     "fieldName": upload.fieldName,
                     "contentType": upload.contentType,
                     "fileName": upload.fileName,
                     "fileSize": upload.fileSize,
                     "tmpFileName": upload.tmpFileName
                     ])
                     */
                    // move file to webroot
                    let thisFile = File(upload.tmpFileName)
                    if (thisFile.path != "") {
                        do {
                            // 本地存放路径（本地即为Mac环境运行）
                            let resultPath = fileDir.path + upload.fileName
                            let _ = try thisFile.moveTo(path: resultPath, overWrite: true)
                            
                            // 服务器绝对路径
                            let absolutePath = resultPath.replacingOccurrences(of: server.documentRoot, with: "")
                            pathArray.append(absolutePath)
                        } catch {
                            response.setBody(string: Utils.failureResponseJson("\(error)"))
                            response.completed()
                        }
                    }
                }
                
                do {
                    try response.setBody(json: Utils.successResponseJson(pathArray))
                    response.completed()
                } catch {
                    response.setBody(string: Utils.failureResponseJson("上传参数错误"))
                    response.completed()
                }
                
            }
        } catch {
            response.setBody(string: Utils.failureResponseJson("\(error)"))
            response.completed()
        }
    }
    // MARK: - 注册
    /**
     * params [String: Any]
     * 1. nickname 昵称
     * 2. mobile 注册手机
     * 3. password 密码
     */
    private func registerHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        var nickname: String = ""
        
        if request.param(name: "nickname") != nil {
            nickname = request.param(name: "nickname")!
        }
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard nickname.count > 0 && mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = ""
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 修改用户信息
    /**
     * params [String: Any]
     * 1. userId 必填
     */
    private func updateAccountHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0..<params.count {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count > 1 || dict["userId"] != nil else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = ""
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 修改密码
    /**
     * params [String: Any]
     * 1. mobile 注册手机
     * 2. password 新密码
     */
    private func resetPasswordHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = ""
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 登录
    /**
     * params [String: Any]
     * 1. mobile 注册手机 (二选一)
     * 2. nickname 昵称 (二选一)
     * 3. password 新密码
     */
    private func loginHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0..<params.count {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 2 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = ""
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 获取用户信息
    /**
     * params [String: Any]
     * 1. userId 用户id 或 用户手机
     * 2. loginId 登录用户id
     */
    private func accountInfoHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        var loginId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        guard userId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = ""
        
        response.appendBody(string: requestJson)
        response.completed()
    }
}
