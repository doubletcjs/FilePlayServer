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
            baseRoutes.add(method: .post, uri: "/login", handler: passwordLoginHandle)
            // 修改密码
            baseRoutes.add(method: .post, uri: "/resetPasswd", handler: resetPasswordHandle)
            // 用户信息
            baseRoutes.add(method: .post, uri: "/accountInfo", handler: accountInfoHandle)
            // 更新用户信息
            baseRoutes.add(method: .post, uri: "/updateAccount", handler: updateAccountHandle)
            
            // 粉丝
            baseRoutes.add(method: .post, uri: "/accountFanList", handler: accountFanListHandle)
            // 关注
            baseRoutes.add(method: .post, uri: "/accountAttentionList", handler: accountAttentionListHandle)
            // 关注用户
            baseRoutes.add(method: .post, uri: "/accountAttention", handler: accountAttentionHandle)
            
            // 插入、更新电影详情
            baseRoutes.add(method: .post, uri: "/movieHandle", handler: movieHandle)
            // 电影详情
            baseRoutes.add(method: .post, uri: "/movieDetail", handler: movieDetailHandle)
            // 想看
            baseRoutes.add(method: .post, uri: "/movieWant", handler: movieWantHandle)
            // 想看、看过列表
            baseRoutes.add(method: .post, uri: "/movieWantWatchList", handler: movieWantWatchListHandle)
            // 看过
            baseRoutes.add(method: .post, uri: "/movieWatch", handler: movieWatchHandle)
            
            // 发动态
            baseRoutes.add(method: .post, uri: "/postDynamic", handler: postDynamicHandle)
            // 动态列表
            baseRoutes.add(method: .post, uri: "/dynamicList", handler: dynamicListHandle)
            // 动态点赞
            baseRoutes.add(method: .post, uri: "/dynamiPraise", handler: dynamiPraiseHandle)
            // 用户动态列表
            baseRoutes.add(method: .post, uri: "/accountDynamicList", handler: accountDynamicListHandle)
            //举报
            baseRoutes.add(method: .post, uri: "/reportFunction", handler: reportFunctionHandle)
            
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
    // MARK: - 举报
    private func reportFunctionHandle(request: HTTPRequest, response: HTTPResponse) {
        var type: String = ""
        
        if request.param(name: "type") != nil {
            type = request.param(name: "type")!
        }
        
        guard type.count != 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        var authorId: String = ""
        if request.param(name: "authorId") != nil {
            authorId = request.param(name: "authorId")!
        }
        
        guard authorId.count != 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        var requestJson = ""
        if type == "0" {
            var userId: String = ""
            if request.param(name: "userId") != nil {
                userId = request.param(name: "userId")!
            }
            
            guard userId.count != 0 else {
                response.setBody(string: Utils.failureResponseJson("请求参数错误"))
                response.completed()
                
                return
            }
            
            requestJson = ReportOperator().reportAccount(authorId, userId)
        } else if type == "1" {
            var dynamicId: String = ""
            if request.param(name: "dynamicId") != nil {
                dynamicId = request.param(name: "dynamicId")!
            }
            
            guard dynamicId.count != 0 else {
                response.setBody(string: Utils.failureResponseJson("请求参数错误"))
                response.completed()
                
                return
            }
            
            requestJson = ReportOperator().reportDynamic(authorId, dynamicId)
        } else if type == "2" {
            var commentId: String = ""
            if request.param(name: "commentId") != nil {
                commentId = request.param(name: "commentId")!
            }
            
            guard commentId.count != 0 else {
                response.setBody(string: Utils.failureResponseJson("请求参数错误"))
                response.completed()
                
                return
            }
            
            requestJson = ReportOperator().reportComment(authorId, commentId)
        }
        
        guard requestJson.count != 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 动态点赞
    private func dynamiPraiseHandle(request: HTTPRequest, response: HTTPResponse) {
        var dynamicId: String = ""
        var authorId: String = ""
        
        if request.param(name: "dynamicId") != nil {
            dynamicId = request.param(name: "dynamicId")!
        }
        
        if request.param(name: "authorId") != nil {
            authorId = request.param(name: "authorId")!
        }
        
        guard dynamicId.count != 0 && authorId.count != 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = DynamicOperator().dynamiPraiseHandle(dynamicId: dynamicId, authorId: authorId)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 用户动态列表
    private func accountDynamicListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = DynamicOperator().accountDynamicList(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 动态列表
    private func dynamicListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = DynamicOperator().dynamicList(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 发动态
    private func postDynamicHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count >= 3 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = DynamicOperator().postDynamicHandle(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 插入、更新电影详情
    private func movieHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count > 1 || dict["userId"] != nil else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = MovieOperator().movieDetailHandle(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 电影详情
    private func movieDetailHandle(request: HTTPRequest, response: HTTPResponse) {
        var loginId: String = ""
        var movieId: String = ""
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        }
        
        guard movieId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = MovieOperator().getMovieDetail(loginId: loginId, movieId: movieId)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 想看电影
    private func movieWantHandle(request: HTTPRequest, response: HTTPResponse) {
        var loginId: String = ""
        var movieId: String = ""
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        }
        
        guard movieId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = MovieOperator().wantMovie(movieId: movieId, loginId: loginId)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 想看、看过列表
    private func movieWantWatchListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 5 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = MovieOperator().wantWatchMovieList(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 看过电影
    private func movieWatchHandle(request: HTTPRequest, response: HTTPResponse) {
        var loginId: String = ""
        var movieId: String = ""
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        if request.param(name: "movieId") != nil {
            movieId = request.param(name: "movieId")!
        } 
        
        guard movieId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = MovieOperator().watchMovie(movieId: movieId, loginId: loginId)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 注册
    private func registerHandle(request: HTTPRequest, response: HTTPResponse) {
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
        
        let requestJson = AccountOperator().registerAccount(mobile: mobile, password: password)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 更新用户信息
    private func updateAccountHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count > 1 || dict["userId"] != nil else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().updateAccount(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 修改密码
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
        
        let requestJson = AccountOperator().resetPassword(mobile: mobile, password: password)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 手机号密码登录
    private func passwordLoginHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 2 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().passwordLogin(params: dict)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 账号信息
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
        
        let requestJson = AccountOperator().getAccount(userId: userId, mobile: "", loginId: loginId)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 用户粉丝列表
    private func accountFanListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().userFanListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 用户关注列表
    private func accountAttentionListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().userAttentionListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 关注用户
    private func accountAttentionHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        if params.count > 0 {
            for idx in 0...params.count-1 {
                let param: (String, String) = params[idx]
                dict[param.0] = param.1
            }
        }
        
        guard dict.keys.count == 2 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().accountAttention(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
}
