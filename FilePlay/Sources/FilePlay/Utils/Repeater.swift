//
//  Repeater.swift
//  FilePlay
//
//  Created by 万烨 on 2019/5/18.
//

import Foundation
import Dispatch

public struct Repeater {
    // Internal queue
    static var operationQueue = DispatchQueue(label: "org.prefect")
    
    /// Exec function for scheduling
    /// timer: (double, number of seconds) indicating execution interval
    /// callback that contains code to run, and returns true if the code is to continue to be executed at the interval.
    public static func exec(timer: Double, callback: @escaping () -> Bool) {
        Repeater.operationQueue.asyncAfter(deadline: .now() + timer) {
            if callback() { Repeater.exec(timer:timer, callback: callback) }
        }
    }
}
