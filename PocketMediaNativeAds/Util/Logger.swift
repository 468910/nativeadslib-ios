//
//  Log.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 11/10/17.
//  Copyright (c) 2017 Pocket Media. All rights reserved.
//
import Foundation
import SwiftyBeaver

/**
 A simple logger.
 */
struct Logger {

    /// The tag prefix each log entry will have.
    static let logger = SwiftyBeaver.self
    static let console = ConsoleDestination()

    static func setup() {
        #if DEBUG
            console.minLevel = logger.Level.debug
        #else
            console.minLevel = logger.Level.info
        #endif
        console.format = "[PocketMediaNativeAds] $DHH:mm:ss$d $L $M"
    }

    static func debug(_ message: String) {
        logger.debug(message)
    }
    
    static func debugf(_ format: String, _ args: CVarArg...) {
        logger.debug(String(format: format, args))
    }


    /// Error log method
    static func error(_ message: String) {
        logger.error(message)
    }
    
    static func error(_ message: String, _ error: Error) {
        logger.error(String(format: "%s: %s", message, error.localizedDescription))
    }
    
    static func errorf(_ format: String, _ args: CVarArg...) {
        logger.error(String(format: format, args))
    }

    /// Error log method with Swift.Error type.
    static func error(_ error: Error) {
        logger.error(String(format: "An error occured: %s", error.localizedDescription))
    }
    
}
