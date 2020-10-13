//
//  ConsoleLogger.swift
//  CoreUtilsKit
//
//  Created by Nguyen Ngoc Minh on 10/9/20.
//  Copyright © 2020 ViettelPay App Team. All rights reserved.
//

import Foundation

public class ConsoleLogger: LogHandler {

    class var shared: ConsoleLogger {
        struct staticView {
            static let instance: ConsoleLogger = ConsoleLogger()
        }
        return staticView.instance
    }

    // MARK: - LogHandler Protocol
    public var logLevel: Level = .debug

    public func log(_ level: Level, message: String, file: String, function: String, line: Int) {
        var text = ""
        text += level.prefix
        text.appendSeparator(contentsOf: message.map({"\($0)"}).joined(separator: ""))
        if !function.isEmpty {
            text.appendSeparator(contentsOf: function)
        }
        if !file.isEmpty {
            text.appendSeparator(contentsOf: file)
        }
        text.append(contentsOf: "\(line)!")
        NSLog(text)
    }
}
