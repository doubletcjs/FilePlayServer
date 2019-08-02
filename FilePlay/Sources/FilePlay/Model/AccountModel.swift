//
//  AccountModel.swift
//  FilePlay
//
//  Created by 万烨 on 2019/8/1.
//

import Foundation

extension NSObject {
    class func getAllPropertys() -> [String] {
        // 这个类型可以使用CUnsignedInt,对应Swift中的UInt32
        var count: UInt32 = 0
        let properties = class_copyPropertyList(self as? AnyClass, &count)
        var propertyNames: [String] = []
        // Swift中类型是严格检查的，必须转换成同一类型
        for i in 0..<Int(count) {
            // UnsafeMutablePointer<objc_property_t>是
            // 可变指针，因此properties就是类似数组一样，可以
            // 通过下标获取
            let property = properties![i]
            let name = property_getName(property)
            // 这里还得转换成字符串
            let strName = String(cString: name) //String.fromCString(name);
            propertyNames.append(strName);
        }
        // 不要忘记释放内存，否则C语言的指针很容易成野指针的
        free(properties)
        return propertyNames;
    }
}

class AccountModel: NSObject {
    // MARK: - 基本内容
    /**
     *     用户id
     */
    @objc var userId: String = ""
    /**
     *    用户名(昵称)
     */
    @objc var nickname: String = ""
    /**
     *    头像
     */
    @objc var portrait: String = ""
    /**
     *     性别 0 未设置 1 男 2 女
     */
    @objc var gender: Int = 0
    /**
     *    手机号码
     */
    @objc var mobile: String = ""
    /**
     *    创建日期 yyyy-MM-dd
     */
    @objc var date: String = ""
    /**
     *    简介
     */
    @objc var introduce: String = ""
    // MARK: - 联表查询
    /**
     *     是否关注
     */
    @objc var isAttention: Bool = false
    /**
     *     关注
     */
    @objc var attentionCount: Int = 0
    /**
     *     粉丝
     */
    @objc var fanCount: Int = 0
}
