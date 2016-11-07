//
//  Log.swift
//  PocketMediaNativeAds, originally from Haneke
//
//  Created by Hermes Pique on 11/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//
import Foundation

struct Logger {

    fileprivate static let Tag = "[PocketMediaNativeAds]"

    fileprivate enum Level: String {
        case Debug = "[DEBUG]"
        case Error = "[ERROR]"
    }

    fileprivate static func log(_ level: Level, _ message: @autoclosure () -> String, _ error: Error? = nil) {
        if let nsError = error as? NSError {
            NSLog("%@%@ %@ with error %@", Tag, level.rawValue, message(), nsError)
        } else {
            NSLog("%@%@ %@", Tag, level.rawValue, message())
        }
    }

    static func debug(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        // #if DEBUG
        log(.Debug, message, error)
        // #endif
    }

    static func debugf(_ format: String, _ args: CVarArg...) {
        #if DEBUG
            log(.Debug, NSString(format, args), error)
        #endif
    }

    static func error(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        log(.Error, message, error)
    }

    static func error(_ error: Error? = nil) {
        log(.Error, "An error occured", error)
    }

    static func errorf(_ format: String, _ args: CVarArg...) {
        #if DEBUG
            log(.Error, NSString(format, args), error)
        #endif
    }
}
