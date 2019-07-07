import Foundation
import CocoaLumberjack

public class Log {

    public init() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        DDLog.add(fileLogger)
    }

    public func debug(_ message: String) {
        DDLogDebug(message)
    }

    public func info(_ message: String) {
        DDLogInfo(message)
    }

    public func warn(_ message: String) {
        DDLogWarn(message)
    }

    public func error(_ message: String) {
        DDLogError(message)
    }

    public func verbose(_ message: String) {
        DDLogVerbose(message)
    }
}
