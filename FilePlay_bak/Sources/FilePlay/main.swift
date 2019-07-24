//
//  main.swift
//  FilePlay
//
//  Created by 4work on 2019/3/7.
//  Copyright © 2019 Sam Cooper Studio. All rights reserved.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger

//MARK: - Log location
private let logPath = "\(kServerDocumentRoot)/logs"
private let logDir = Dir(logPath)
if !logDir.exists {
    try Dir(logPath).create()
}

LogFile.location = "\(logPath)/Server.log"

// MARK: - Configure routes
private var routes = BasicRoutes().routes

// MARK: - Configure server
let server = HTTPServer()
server.addRoutes(routes)
server.serverPort = kServerPort
server.serverName = kServerName
server.documentRoot = kServerDocumentRoot
server.setResponseFilters([
    (try PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

// MARK: - Start server
do {
    LogFile.info("Server Start Successful")
    try server.start()
} catch let error {
    LogFile.error("Failure Start Server：\(error)")
}

