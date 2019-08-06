import Foundation
import CocoaLumberjack

class Log {

    init() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        DDLog.add(fileLogger)
    }

    func debug(_ message: String) {
        DDLogDebug(message)
    }

    func info(_ message: String) {
        DDLogInfo(message)
    }

    func warn(_ message: String) {
        DDLogWarn(message)
    }

    func error(_ message: String) {
        DDLogError(message)
    }

    func verbose(_ message: String) {
        DDLogVerbose(message)
    }
}
