//
//  ReportOperator.swift
//  FilePlay
//
//  Created by 4work on 2019/4/19.
//

import Foundation

class ReportOperator: DataBaseOperator {
    // MARK: - 举报用户
    private func reportAccount(_ authorId: String, _ userId: String) -> Void {
        let statement = "INSERT INTO \(reportusertable) (authorId, userId) VALUES ('\(authorId)', '\(userId)')"
        if mysql.query(statement: statement) == false {
            Utils.logError("举报用户", mysql.errorMessage())
        } else {
            print("举报用户成功")
        }
    }
    // MARK: - 举报动态
    private func reportDynamic(_ authorId: String, _ dynamicId: String) -> Void {
        let statement = "INSERT INTO \(reportdynamictable) (authorId, dynamicId) VALUES ('\(authorId)', '\(dynamicId)')"
        if mysql.query(statement: statement) == false {
            Utils.logError("举报动态", mysql.errorMessage())
        } else {
            print("举报动态成功")
        }
    }
    // MARK: - 举报评论
    private func reportComment(_ authorId: String, _ commentId: String) -> Void {
        let statement = "INSERT INTO \(reportcommenttable) (authorId, commentId) VALUES ('\(authorId)', '\(commentId)')"
        if mysql.query(statement: statement) == false {
            Utils.logError("举报评论", mysql.errorMessage())
        } else {
            print("举报评论成功")
        }
    }
}
