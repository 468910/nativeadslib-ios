//
//  Log.swift
//  PocketMediaNativeAds, originally from Haneke
//
//  Created by Hermes Pique on 11/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//
import Foundation

/**
 A simple logger.
 */
struct Logger {

    /// The tag prefix each log entry will have.
    fileprivate static let Tag = "[PocketMediaNativeAds]"

    /// The log levels
    fileprivate enum Level: String {
        case Debug = "[DEBUG]"
        case Error = "[ERROR]"
    }

    /// Write the std using NSLOG.
    fileprivate static func log(_ level: Level, _ message: @autoclosure () -> String, _ error: Error? = nil) {
        if let nsError = error as? NSError {
            NSLog("%@%@ %@ with error %@", Tag, level.rawValue, message(), nsError)
        } else {
            NSLog("%@%@ %@", Tag, level.rawValue, message())
        }
    }

    /// Debug log method
    static func debug(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        #if DEBUG
            log(.Debug, message, error)
        #endif
    }

    /// Debug format log method
    static func debugf(_ format: String, _ args: CVarArg...) {
        #if DEBUG
            log(.Debug, NSString(format, args), error)
        #endif
    }

    /// Error log method
    static func error(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        log(.Error, message, error)
    }

    /// Error log method with Swift.Error type.
    static func error(_ error: Error? = nil) {
        log(.Error, "An error occured", error)
    }

    /// Error format log method
    static func errorf(_ format: String, _ args: CVarArg...) {
        #if DEBUG
            log(.Error, NSString(format, args), error)
        #endif
    }
}
