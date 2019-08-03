//
//  TopicModel.swift
//  FilePlay
//
//  Created by 万烨 on 2019/8/3.
//

import Foundation

class TopicModel: DataBaseOperator {
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
