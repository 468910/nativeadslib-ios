/**
 A simple logger.
 */
class Logger {
    
    // Enum for showing the type of Log Types
    enum LogEvent: String {
        case error = "[‼️]" // error
        case info = "[ℹ️]" // info
        case debug = "[💬]" // debug
        case verbose = "[🔬]" // verbose
        case warning = "[⚠️]" // warning
        case severe = "[🔥]" // severe
    }
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private class func log(message: String,
                           event: LogEvent,
                           fileName: String = #file,
                           line: Int = #line,
                           column: Int = #column,
                           funcName: String = #function) {
        #if DEBUG
            
        #else
            if event == .debug {
                return
            }
        #endif
        print("[PocketMediaNativeAds] \(Date().toString()) \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)")
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    class func debug(_ message: String,
                     fileName: String = #file,
                     line: Int = #line,
                     column: Int = #column,
                     funcName: String = #function) {
        Logger.log(
            message: message,
            event: .debug,
            fileName: fileName,
            line: line,
            column: column,
            funcName: funcName)
    }
    
    class func debugf(fileName: String = #file,
                      line: Int = #line,
                      column: Int = #column,
                      funcName: String = #function,
                      _ format: String,
                      _ args: CVarArg...) {
        Logger.log(
            message: String(format: format, args),
            event: .debug,
            fileName: fileName,
            line: line,
            column: column,
            funcName: funcName)
    }
    
    class func error(_ message: String,
                     fileName: String = #file,
                     line: Int = #line,
                     column: Int = #column,
                     funcName: String = #function) {
        Logger.log(
            message: message,
            event: .error,
            fileName: fileName,
            line: line,
            column: column,
            funcName: funcName)
    }
    
    class func errorf(fileName: String = #file,
                      line: Int = #line,
                      column: Int = #column,
                      funcName: String = #function,
                      _ format: String,
                      _ args: CVarArg...) {
        Logger.log(
            message: String(format: format, args),
            event: .error,
            fileName: fileName,
            line: line,
            column: column,
            funcName: funcName)
    }
    
    class func error(_ message: String,
                     _ error: Error,
                     fileName: String = #file,
                     line: Int = #line,
                     column: Int = #column,
                     funcName: String = #function) {
        Logger.log(
            message: String(format: "%s: %s", message, error.localizedDescription),
            event: .error,
            fileName: fileName,
            line: line,
            column: column,
            funcName: funcName)
    }
    
    class func error(_ error: Error,
                     fileName: String = #file,
                     line: Int = #line,
                     column: Int = #column,
                     funcName: String = #function) {
        Logger.log(
            message: String(format: "An error occured: %s", error.localizedDescription),
            event: .error,
            fileName: fileName,
            line: line,
            column: column,
            funcName: funcName)
    }
}

internal extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
