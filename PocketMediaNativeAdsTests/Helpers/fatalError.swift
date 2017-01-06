//
//  fatalError.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 12/09/16.
//
//
import XCTest
import Foundation
import UIKit

    /// / overrides Swift global `fatalError`
    // func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    //    FatalErrorUtil.fatalErrorClosure(message(), file, line)
    //    unreachable()
    // }
    //
    /// // This is a `noreturn` function that pauses forever
    // func unreachable() -> Never {
    //    repeat {
    //        RunLoop.current.run()
    //    } while (true)
    // }
    //
    /// // Utility functions that can replace and restore the `fatalError` global function.
    // struct FatalErrorUtil {
    //
    //    // Called by the custom implementation of `fatalError`.
    //    static var fatalErrorClosure: (String, StaticString, UInt) -> Void = defaultFatalErrorClosure
    //
    //    // backup of the original Swift `fatalError`
    //    fileprivate static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    //
    //    /// Replace the `fatalError` global function with something else.
    //    static func replaceFatalError(_ closure: @escaping (String, StaticString, UInt) -> Void) {
    //        fatalErrorClosure = closure
    //    }
    //
    //    /// Restore the `fatalError` global function back to the original Swift implementation
    //    static func restoreFatalError() {
    //        fatalErrorClosure = defaultFatalErrorClosure
    //    }
    // }
    //
    // extension XCTestCase {
    //    func expectFatalError(_ expectedMessage: String, testcase: @escaping () -> Void) {
    //
    //        // arrange
    //        let expectation = self.expectation(description: "expectingFatalError")
    //        var assertionMessage: String? = nil
    //
    //        // override fatalError. This will pause forever when fatalError is called.
    //        FatalErrorUtil.replaceFatalError { message, _, _ in
    //            assertionMessage = message
    //            expectation.fulfill()
    //        }
    //
    //        // act, perform on separate thead because a call to fatalError pauses forever
    //        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: testcase)
    //
    //        waitForExpectations(timeout: 0.1) { _ in
    //            // assert
    //            XCTAssertEqual(assertionMessage, expectedMessage)
    //
    //            // clean up
    //            FatalErrorUtil.restoreFatalError()
    //        }
    //    }
    // }
    =======
    // overrides Swift global `fatalError`
    @noreturn func fatalError(@autoclosure message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
    unreachable()
}

/// This is a `noreturn` function that pauses forever
@noreturn func unreachable() {
    repeat {
        NSRunLoop.currentRunLoop().run()
    } while true
}

/// Utility functions that can replace and restore the `fatalError` global function.
struct FatalErrorUtil {

    // Called by the custom implementation of `fatalError`.
    static var fatalErrorClosure: (String, StaticString, UInt) -> Void = defaultFatalErrorClosure

    // backup of the original Swift `fatalError`
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }

    /// Replace the `fatalError` global function with something else.
    static func replaceFatalError(closure: (String, StaticString, UInt) -> Void) {
        fatalErrorClosure = closure
    }

    /// Restore the `fatalError` global function back to the original Swift implementation
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}

extension XCTestCase {
    func expectFatalError(expectedMessage: String, testcase: () -> Void) {

        // arrange
        let expectation = expectationWithDescription("expectingFatalError")
        var assertionMessage: String?

        // override fatalError. This will pause forever when fatalError is called.
        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
        }

        // act, perform on separate thead because a call to fatalError pauses forever
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), testcase)

        waitForExpectationsWithTimeout(0.1) { _ in
            // assert
            XCTAssertEqual(assertionMessage, expectedMessage)

            // clean up
            FatalErrorUtil.restoreFatalError()
        }
    }
}
