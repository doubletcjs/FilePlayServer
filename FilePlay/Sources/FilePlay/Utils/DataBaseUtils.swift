//
//  DataBaseUtils.swift
//  FilePlay
//
//  Created by 4work on 2019/3/8.
//

import Foundation
import PerfectMySQL
import PerfectRepeater

private let dataBaseName = kProjectName
private let host = "127.0.0.1"  //数据库IP
private let port = "3306"   //数据库端口
private let user = "root"   //数据库用户名
private let password = "8707gtt04cjsd,./"   //数据库密码

public let accounttable = "account_table"
public let reportusertable = "report_user"
public let attentionfantable = "attention_fan"

public let movietable = "movie_table"

public let watchmovietable = "watch_movie"
public let wantmovietable = "want_movie"

public let dynamictable = "dynamic_table"
public let reportdynamictable = "report_dynamic"
public let praisedynamictable  = "praise_dynamic"

public let commenttable = "comment_table"
public let reportcommenttable = "report_comment"
public let praisecommenttable  = "praise_comment"

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
        
        Utils.logError("连接数据库", "成功")
    }
    
    // MARK: - 选择数据库Scheme
    ///
    /// - Parameter name: Scheme名
    private func selectDataBase(name: String) {
        // 选择具体的数据Schema
        guard connect.selectDatabase(named: name) else {
            Utils.logError("连接Schema", "错误代码：\(connect.errorCode()) 错误解释：\(connect.errorMessage())")
            return
        }
        
        Utils.logError("连接Schema：", "\(name)成功")
        
        let checkDatabase = { () -> Bool in
            print("检测数据库")
            
            let statement = "SELECT COUNT(DISTINCT \(accounttable).userId) FROM \(accounttable)"
            if connect.query(statement: statement) == false {
                Utils.logError("检测数据库", "失败：\(connect.errorMessage())")
            } else {
                Utils.logError("检测数据库", "成功")
            }
            
            return true
        }
        
        Repeater.exec(timer: 60*2, callback: checkDatabase)
//        let timer = Timer.scheduledTimer(timeInterval: 60*2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
//        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
    }
    
//    private func timerAction() -> Void {
//        let statement = "SELECT COUNT(DISTINCT \(accounttable).userId) FROM \(accounttable)"
//        if connect.query(statement: statement) == false {
//            Utils.logError("连接数据库", "失败：\(connect.errorMessage())")
//        } else {
//            Utils.logError("检测数据库成功！", "成功")
//        }
//    }
}
// MARK: - 操作数据库的基类
class DataBaseOperator {
    var mysql: MySQL {
        get {
            return DataBaseConnent.shareInstance(dataBaseName: dataBaseName)
        }
    }
    
    var responseJson: String! = ""
}
