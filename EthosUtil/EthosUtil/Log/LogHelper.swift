//
//  LogHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

fileprivate let CHECK_CONDITION_TEMPLATE = """

File: %@ (Line: %d)
Message: %@

"""

/**
 The LogHelper class serves as the logging backbone for the Ethos ecosystem.
 
 It maintains a whitelist of allowable tags and only shows those messages - the whitelist can be modified at any time.
 By default, the white list begins with the warning and the error tags.
 
 You can set the LogDelegate instance to receive log messages for the whitelisted tags and add custom handling.
 */
open class LogHelper {
    
    // MARK: - Constants & Types
    private static let BACKGROUND_THREAD_NAME = "__RESERVED__.Log"
    
    public enum Tag: String {
        case Info = "Info"
        case Debug = "Debug"
        case Warning = "Warn"
        case Error = "Error"
    }
    
    public typealias Delegate = LogHelperDelegate
    
    // MARK: - Builders & Constructors
    private init() {
        self.showLogs(tag: LogHelper.Tag.Warning.rawValue)
        self.showLogs(tag: LogHelper.Tag.Error.rawValue)
    }
    
    // MARK: - Singleton & Delegate
    public static let shared = LogHelper()
    
    open weak var logHelperDelegate: LogHelper.Delegate?
    
    // MARK: - State Variables
    private var tagWhiteList = Set<String>()
    
    /**
     Set this member to true to ignore the whitelist and show all logs
     */
    open var SHOW_ALL = false
    
    // MARK: - Whitelist methods
    open func showLogs(tag: String) {
        tagWhiteList.insert(tag)
    }
    
    open func showLogs(tag: LogHelper.Tag) {
        self.showLogs(tag: tag.rawValue)
    }
    
    open func hideLogs(tag: String) {
        tagWhiteList.remove(tag)
    }
    
    open func hideLogs(tag: LogHelper.Tag) {
        self.hideLogs(tag: tag.rawValue)
    }
    
    // MARK: - Logging Methods
    open func log(msg: String, tag: LogHelper.Tag = LogHelper.Tag.Debug) {
        self.log(msg: msg, tag: tag.rawValue)
    }
    
    open func log(msg: String, tag: String) {
        if !self.shouldShowLog(tag: tag) { return }
        ThreadHelper.executeOnApplicationQueue(name: LogHelper.BACKGROUND_THREAD_NAME) {
            // Only handle the message once, either with the logDelegate or with the default handler
            
            var handler: ((String) -> Void)?
            switch (tag) {
            case LogHelper.Tag.Info.rawValue:
                handler = self.logHelperDelegate?.info
            case LogHelper.Tag.Debug.rawValue:
                handler = self.logHelperDelegate?.debug
            case LogHelper.Tag.Warning.rawValue:
                handler = self.logHelperDelegate?.warning
            case LogHelper.Tag.Error.rawValue:
                handler = self.logHelperDelegate?.error
            default:
                break
            }
            
            if let h = handler {
                h(msg)
                return
            } else if let delegate = self.logHelperDelegate {
                delegate.log(msg: msg, tag: tag)
            } else {
                print("[\(tag)] - \(msg)")
            }
        }
    }
    
    /**
     This method is similar to the assert(..) function but only for debug builds. For production builds it is a noop
     
     - parameters:
         - condition: An expression tha should be true.
         - message: A message to display if the condition is false
         - file: the source file
         - line: the source line
     */
    open func checkCondition(condition: Bool, message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        if !condition {
            let fileName = (file.split(separator: "/").last ?? "No File") as CVarArg
            checkCondition(message: String(format: CHECK_CONDITION_TEMPLATE, fileName, line, message))
        }
        #endif
    }
    
    /**
     This method is similar to the assert(..) function but only for debug builds. For production builds it is a noop
     
     - parameters:
         - condition: An expression tha should be true.
         - parameters: A dictionary of information that should be relevant should the condition be false
         - file: the source file
         - line: the source line
     */
    open func checkCondition(condition: Bool, parameters: [String: Any], file: String = #file, line: Int = #line) {
        #if DEBUG
        if !condition {
            let message = "parameters = \(parameters)"
            let fileName = (file.split(separator: "/").last ?? "No File") as CVarArg
            checkCondition(message: String(format: CHECK_CONDITION_TEMPLATE, fileName, line, message))
        }
        #endif
    }
    
    // MARK: - Helper Methods
    private func shouldShowLog(tag: String) -> Bool {
        return SHOW_ALL || tagWhiteList.contains(tag)
    }
    
    private func checkCondition(message: String) {
        #if DEBUG
        if let handler = self.logHelperDelegate?.checkConditionFailed {
            handler(message)
        } else {
            print(message)
            fatalError()
        }
        #endif
    }
    
}
