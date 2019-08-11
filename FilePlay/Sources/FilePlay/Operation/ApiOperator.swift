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
import PerfectCURL

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
            
            // MARK: - 用户
            // 注册
            baseRoutes.add(method: .post, uri: "/register", handler: AccountOperator().registerHandle(request:response:))
            // 手机号密码登录
            baseRoutes.add(method: .post, uri: "/login", handler: AccountOperator().loginHandle(request:response:))
            // 修改密码
            baseRoutes.add(method: .post, uri: "/resetPasswd", handler: AccountOperator().resetPasswordHandle(request:response:))
            // 用户信息
            baseRoutes.add(method: .post, uri: "/accountInfo", handler: AccountOperator().accountInfoHandle(request:response:))
            // 更新用户信息
            baseRoutes.add(method: .post, uri: "/updateAccount", handler: AccountOperator().updateAccountHandle(request:response:))
            // 粉丝列表
            baseRoutes.add(method: .post, uri: "/accountFanList", handler: AccountOperator().accountFanListHandle(request:response:))
            // 关注列表
            baseRoutes.add(method: .post, uri: "/accountAttentionList", handler: AccountOperator().accountAttentionListHandle(request:response:))
            // 关注、取消关注
            baseRoutes.add(method: .post, uri: "/accountAttentionStatus", handler: AccountOperator().accountAttentionStatusHandle(request:response:))
            
            // MARK: - 电影
            // 收藏
            baseRoutes.add(method: .post, uri: "/movieCollectionStatus", handler: MovieOperater().movieCollectionStatusHandle(request:response:))
            // 已看
            baseRoutes.add(method: .post, uri: "/movieWatchStatus", handler: MovieOperater().movieWatchStatusHandle(request:response:))
            // 更新电影
            baseRoutes.add(method: .post, uri: "/updateMovie", handler: MovieOperater().updateMovieHandle(request:response:))
            // 电影详情
            baseRoutes.add(method: .post, uri: "/movieDetail", handler: MovieOperater().movieDetailHandle(request:response:))
            // 电影动态列表
            baseRoutes.add(method: .post, uri: "/movieDynamicList", handler: DynamicOperator().movieDynamicListHandle(request:response:))
            
            // MARK: - 用户主页
            // 用户主页信息
            baseRoutes.add(method: .post, uri: "/accountHomePage", handler: AccountOperator().accountHomePageHandle(request:response:)) 
            
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
}
