//
//  Log.swift
//  PocketMediaNativeAds, originally from Haneke
//
//  Created by Hermes Pique on 11/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//
import Foundation

struct Logger {

    private static let Tag = "[PocketMediaNativeAds]"

    private enum Level: String {
        case Debug = "[DEBUG]"
        case Error = "[ERROR]"
    }

    private static func log(_ level: Level, _ message: String, _ error: Error? = nil) {
        if let error = error {
//            NSLog("%@%@ %@ with error %@", Tag, level.rawValue, message, error)
        } else {
            NSLog("%@%@ %@", Tag, level.rawValue, message)
        }
    }

    public static func debug(_ message: String, _ error: Error? = nil) {
        //#if DEBUG
            log(.Debug, message, error)
        //#endif
    }

    public static func debugf(_ format: String, _ args: CVarArg...) {
        #if DEBUG
            log(.Debug, NSString(format, args), error)
        #endif
    }

    public static func error(_ message: String, _ error: Error? = nil) {
        log(.Error, message, error)
    }
    
    public static func error(_ error: Error? = nil) {
        log(.Error, "An error occured", error)
    }

}
