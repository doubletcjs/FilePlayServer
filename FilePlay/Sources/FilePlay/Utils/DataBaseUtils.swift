//
//  DataBaseUtils.swift
//  FilePlay
//
//  Created by 4work on 2019/3/8.
//

import Foundation
import PerfectMySQL 

private let dataBaseName = kProjectName.lowercased()
private let host = "106.12.107.176"  //数据库IP
private let port = "3306"   //数据库端口
private let user = "doubletcjs"   //数据库用户名
private let password = "8707gtt04cjsd,./"   //数据库密码

// MARK: - 评论
public let db_comment = "comment_table"
public let db_praise_comment = "praise_comment"
public let db_report_comment = "report_comment"

// MARK: - 话题
public let db_topic = "topic_table"

// MARK: - 动态
public let db_dynamic = "dynamic_table"
public let db_praise_dynamic = "praise_dynamic"
public let db_report_dynamic = "report_dynamic"

// MARK: - 用户
public let db_account = "account_table"
public let db_attention_fan = "attention_fan"
public let db_report_account = "report_account"

// MARK: - 电影
public let db_movie = "movie_table"
public let db_watch_movie = "watch_movie"
public let db_collection_movie = "collection_movie"

// MARK: - 连接MySql数据库的类
class DataBaseConnent {
    private var connect: MySQL! //用于操作MySql的句柄
    
    // MARK: - MySQL句柄单例
    private static var instance: MySQL!
    public static func shareInstance(dataBaseName: String) -> MySQL {
        if instance == nil {
            instance = DataBaseConnent(dataBaseName: dataBaseName).connect
        }
        
        return instance
    }
    
    private init(dataBaseName: String) {
        self.connectDataBase()
        self.selectDataBase(name: dataBaseName)
    }
    
    // MARK: - 连接数据库
    private func connectDataBase() {
        if connect == nil {
            connect = MySQL()
        }
        
        let connected = connect.connect(host: "\(host)", user: user, password: password)
        guard connected else {
            // 验证一下连接是否成功
            Utils.logError("连接数据库", "失败：\(connect.errorMessage())")
            return
        }
        
        connect.setOption(MySQLOpt.MYSQL_OPT_RECONNECT, true)
        Utils.logInfo("连接数据库", "成功")
    }
    
    // MARK: - 选择数据库Scheme
    ///
    /// - Parameter name: Scheme名
    private func selectDataBase(name: String) {
        // 选择具体的数据Schema
        guard connect.selectDatabase(named: name) else {
            Utils.logInfo("连接Schema", "错误代码：\(connect.errorCode()) 错误解释：\(connect.errorMessage())")
            return
        }
        
        Utils.logInfo("连接Schema：\(name)", "成功")
    }
}
// MARK: - 操作数据库的基类
class DataBaseOperator: NSObject {
    var mysql: MySQL {
        get {
            return DataBaseConnent.shareInstance(dataBaseName: dataBaseName)
        }
    }
    
    var responseJson: String! = ""
}
