//
//  ReportOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/4/19.
//

import Foundation

class ReportOperator: DataBaseOperator {
    // MARK: - 是否已举报
    private func checkIsReport(_ type: Int, _ authorId: String, _ objectId: String) -> Bool {
        var tableName = reportusertable
        var tip = "用户"
        var statement = "SELECT objectId FROM \(tableName) WHERE \(tableName).authorId = '\(authorId)' AND \(tableName).userId = '\(objectId)'"
        
        if type == 1 {
            tableName = reportdynamictable
            statement = "SELECT objectId FROM \(tableName) WHERE \(tableName).authorId = '\(authorId)' AND \(tableName).dynamicId = '\(objectId)'"
            tip = "动态"
        } else if type == 2 {
            tableName = reportcommenttable
            statement = "SELECT objectId FROM \(tableName) WHERE \(tableName).authorId = '\(authorId)' AND \(tableName).commentId = '\(objectId)'"
            tip = "评论"
        }
        
        if mysql.query(statement: statement) == false {
            Utils.logError("举报\(tip)查询", mysql.errorMessage())
            return false
        } else {
            let results = mysql.storeResults()!
            if results.numRows() > 0 {
                return true
            } else {
                return false
            }
        }
    }
    // MARK: - 举报用户
    func reportAccount(_ authorId: String, _ userId: String) -> String {
        if checkIsReport(0, authorId, userId) {
            responseJson = Utils.successResponseJson("已举报")
        } else {
            let statement = "INSERT INTO \(reportusertable) (authorId, userId) VALUES ('\(authorId)', '\(userId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("举报用户", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("举报用户失败")
            } else {
                responseJson = Utils.successResponseJson("举报用户成功")
            }
        }
        
        return responseJson
    }
    // MARK: - 举报动态
    func reportDynamic(_ authorId: String, _ dynamicId: String) -> String {
        if checkIsReport(1, authorId, dynamicId) {
            responseJson = Utils.successResponseJson("已举报")
        } else {
            let statement = "INSERT INTO \(reportdynamictable) (authorId, dynamicId) VALUES ('\(authorId)', '\(dynamicId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("举报动态", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("举报动态失败")
            } else {
                responseJson = Utils.successResponseJson("举报动态成功")
            }
        }
        
        return responseJson
    }
    // MARK: - 举报评论
    func reportComment(_ authorId: String, _ commentId: String) -> String {
        if checkIsReport(2, authorId, commentId) {
            responseJson = Utils.successResponseJson("已举报")
        } else {
            let statement = "INSERT INTO \(reportcommenttable) (authorId, commentId) VALUES ('\(authorId)', '\(commentId)')"
            if mysql.query(statement: statement) == false {
                Utils.logError("举报评论", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("举报评论失败")
            } else {
                responseJson = Utils.successResponseJson("举报评论成功")
            }
        }
        
        return responseJson
    }
}
