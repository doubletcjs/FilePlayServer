//
//  TopicModel.swift
//  FilePlay
//
//  Created by 4work on 2019/8/3.
//

import Foundation

class TopicModel: DataBaseOperator {
    class func getAllPropertys() -> [String] {
        return [
            "topicId",
            "topicName",
            "createDate"];
    }
    
    /**
     *     话题id
     */
    @objc var topicId: String = ""
    /**
     *    话题名称
     */
    @objc var topicName: String = ""
    /**
     *    发布日期 yyyy-MM-dd HH:mm:ss
     */
    @objc var createDate: String = ""
}
