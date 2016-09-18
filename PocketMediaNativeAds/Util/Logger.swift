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

    private static func log(level: Level, @autoclosure _ message: () -> String, _ error: NSError? = nil) {
        if let error = error {
            NSLog("%@%@ %@ with error %@", Tag, level.rawValue, message(), error)
        } else {
            NSLog("%@%@ %@", Tag, level.rawValue, message())
        }
    }

    static func debug(@autoclosure message: () -> String, _ error: NSError? = nil) {
        #if DEBUG
            log(.Debug, message, error)
        #endif
    }

    static func debugf(format: String, _ args: CVarArgType...) {
        #if DEBUG
            log(.Debug, NSString(format, args), error)
        #endif
    }

    static func error(@autoclosure message: () -> String, _ error: NSError? = nil) {
        log(.Error, message, error)
    }

}
