//
//  FileLogger.swift
//  CoreUtilsKit
//
//  Created by Nguyen Ngoc Minh on 10/5/20.
//  Copyright © 2020 ViettelPay App Team. All rights reserved.
//

import Foundation

let fileNameLogger = "VDSLogger.log"

public class FileLogger: NSObject, LogHandler {

    class var shared: FileLogger {
        struct staticView {
            static let instance: FileLogger = FileLogger()
        }
        return staticView.instance
    }

    var logFileURL: URL?
    var syncAfterEachWrite: Bool = false
    let fileManager = FileManager.default

    func checkFileExisting(_ completion: @escaping (URL?) -> (Void)) {
        if let logFileURL = logFileURL {
            self.logFileURL = logFileURL
            completion(logFileURL)
        }

        /// platform-dependent logfile directory default
        var baseURL: URL?
        #if os(OSX)
        if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            baseURL = url
            /// try to use ~/Library/Caches/APP NAME instead of ~/Library/Caches
            if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
                do {
                    if let appURL = baseURL?.appendingPathComponent(appName, isDirectory: true) {
                        try fileManager.createDirectory(at: appURL,
                                                        withIntermediateDirectories: true, attributes: nil)
                        baseURL = appURL
                    }
                } catch {
                    print("Warning! Could not create folder /Library/Caches/\(appName)")
                }
            }
        }
        #else
        #if os(Linux)
        baseURL = URL(fileURLWithPath: "/var/cache")
        #else
        /// iOS, watchOS, etc. are using the caches directory
        if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            baseURL = url
        }
        #endif
        #endif

        if let baseURL = baseURL {
            self.logFileURL = baseURL.appendingPathComponent(fileNameLogger, isDirectory: false)
        }
        completion(self.logFileURL)
    }

    // MARK: - LogHandler Protocol
    public var logLevel: Level  = .debug

    public func log(_ level: Level, message: String, file: String, function: String, line: Int) {
        self.checkFileExisting { (fileURL) -> (Void) in
            if let url = fileURL {
                var text = ""
                text.appendSeparator(contentsOf: level.timeStamp)
                text.appendSeparator(contentsOf: message.map({"\($0)"}).joined(separator: ""))
                if !function.isEmpty {
                    text.appendSeparator(contentsOf: function)
                }
                if !file.isEmpty {
                    text.appendSeparator(contentsOf: file)
                }
                text.append(contentsOf: "\(line)!\n")

                guard let data = text.data(using: String.Encoding.utf8) else {
                    return
                }

                // check file size and then save over data
                if self.checkFileSize() {
                    if self.deleteLogFile() {
                        debugPrint("Success")
                    }
                }
                _ = self.write(data: data, to: url)
            }
        }
    }

    //MARK: - Private Func
    private func deleteLogFile() -> Bool {
        guard let url = logFileURL,
            fileManager.fileExists(atPath: url.path) == true else { return false }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            debugPrint("VDSLogger could not remove file \(url).")
            return false
        }
    }

    private func checkFileSize() -> Bool {
        var text = ""
        var result = [String]()

        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileNameLogger)
            do {
                text = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
        if !text.isEmpty {
            result = text.components(separatedBy: "\n")
        }
        if result.count > 5120 {
            /// delete file when it have more 5120 records
            return true
        }
        return false
    }

    private func write(data: Data, to url: URL) -> Bool {
        var success = false
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?
        coordinator.coordinate(writingItemAt: url, error: &error) { url in
            do {
                if fileManager.fileExists(atPath: url.path) == false {

                    let directoryURL = url.deletingLastPathComponent()
                    if fileManager.fileExists(atPath: directoryURL.path) == false {
                        try fileManager.createDirectory(
                            at: directoryURL,
                            withIntermediateDirectories: true
                        )
                    }
                    fileManager.createFile(atPath: url.path, contents: nil)

                    #if os(iOS) || os(watchOS)
                    if #available(iOS 10.0, watchOS 3.0, *) {
                        var attributes = try fileManager.attributesOfItem(atPath: url.path)
                        attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                        try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
                    }
                    #endif
                }

                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                if syncAfterEachWrite {
                    fileHandle.synchronizeFile()
                }
                fileHandle.closeFile()
                success = true
            } catch {
                debugPrint("VDSLogger could not write to file \(url).")
            }
        }

        if let error = error {
            debugPrint("Failed writing file with error: \(String(describing: error))")
            return false
        }

        return success
    }
}
