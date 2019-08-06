//
//  Networking.swift
//  FilePlay
//
//  Created by 万烨 on 2019/8/6.
//

import Foundation
import PerfectCURL 

typealias NetResponseResultBlock = (_ obj: Any?, _ aError: NSError?) -> Void

class Networking: NSObject {
    class func requestFunction(_ url: String, _ params: [String: Any], _ method: CURLRequest.HTTPMethod, completionHandler: NetResponseResultBlock?) -> Void {
        var requestUrl = url
        var options: [CURLRequest.Option] = []
        options.append(CURLRequest.Option.httpMethod(method))
        
        if method == .post {
            params.forEach { (key, value) in
                options.append(CURLRequest.Option.postField(.init(name: "\(key)", value: "\(value)")))
            }
        } else if method == .get {
            var getKeys: [String] = []
            params.forEach { (key, value) in
                getKeys.append("\(key)=\(value)")
            }
            
            if getKeys.count > 0 {
                if getKeys.count == 1 {
                    requestUrl = requestUrl+getKeys.first!
                } else {
                    requestUrl = requestUrl+"?"+getKeys.joined(separator: "&")
                }
            }
        } else {
            if completionHandler != nil {
                let error: NSError = NSError.init(domain: "HTTP方法错误", code: -999, userInfo: [NSLocalizedDescriptionKey: "HTTP方法只支持GET、POST"])
                completionHandler!(nil, error)
            }
            
            return
        }
        
        CURLRequest.init(requestUrl, options: options).perform { confirmation in
            do {
                let response = try confirmation()
                let json: [String: Any] = response.bodyJSON
                
                print("json： \(json)")
                if completionHandler != nil {
                    completionHandler!(json, nil)
                }
            } catch let error as CURLResponse.Error {
                print("出错，响应代码为： \(error.response.responseCode)")
                if completionHandler != nil {
                    let error: NSError = NSError.init(domain: "CURLRequest请求失败", code: error.response.responseCode, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                    completionHandler!(nil, error)
                }
            } catch {
                print("致命错误： \(error)")
                if completionHandler != nil {
                    let error: NSError = NSError.init(domain: "CURLRequest致命错误", code: -999, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                    completionHandler!(nil, error)
                }
            }
        }
    }
}
