import Foundation
import CocoaLumberjack


final class Log: DDAbstractLogger
{
    // MARK: Constants
    static let delimiter = "----------------------------------------------------------------------------------------------------"
    static let defaultCategory = String.Empty
    static let separator = String.Space
    static let prompt = "> "
    static let terminator = String.LF
    static let minFreeDiskSpaceRequired: Int64 = 100

    static let logFolderName = "app-logs"
    static var logFolderPath: String
    {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/\(logFolderName)")
    }

    // MARK: Variables
    private var _fileLoggingEnabled = true


    // MARK: Constructor
    private override init()
    {
        super.init()
    }


    // MARK: Instance
    private static let instance = Log()


    static func debug(category: String = defaultCategory, _ items: Any..., file: String = #file, function: String = #function, line: UInt = #line)
    {
        let itemsString = items.map { "\($0)" }.joined(separator: separator)
        let logMessage = DDLogMessage(message: itemsString, level: .debug, flag: .debug, context: 0, file: file, function: function, line: line, tag: category, options: [], timestamp: Date())
        instance.log(message: logMessage)
    }


    static func info(category: String = defaultCategory, _ items: Any..., file: String = #file, function: String = #function, line: UInt = #line)
    {
        let itemsString = items.map { "\($0)" }.joined(separator: separator)
        let logMessage = DDLogMessage(message: itemsString, level: .info, flag: .info, context: 0, file: file, function: function, line: line, tag: category, options: [], timestamp: Date())
        instance.log(message: logMessage)
    }


    static func warning(category: String = defaultCategory, _ items: Any..., file: String = #file, function: String = #function, line: UInt = #line)
    {
        let itemsString = items.map { "\($0)" }.joined(separator: separator)
        let logMessage = DDLogMessage(message: itemsString, level: .warning, flag: .warning, context: 0, file: file, function: function, line: line, tag: category, options: [], timestamp: Date())
        instance.log(message: logMessage)
    }


    static func error(category: String = defaultCategory, _ items: Any..., file: String = #file, function: String = #function, line: UInt = #line)
    {
        let itemsString = items.map { "\($0)" }.joined(separator: separator)
        let logMessage = DDLogMessage(message: itemsString, level: .error, flag: .error, context: 0, file: file, function: function, line: line, tag: category, options: [], timestamp: Date())
        instance.log(message: logMessage)
    }


    static func delimiter(file: String = #file, function: String = #function, line: UInt = #line)
    {
        let logMessage = DDLogMessage(message: delimiter, level: .info, flag: .info, context: 0, file: file, function: function, line: line, tag: defaultCategory, options: [], timestamp: Date())
        instance.log(message: logMessage)
    }


    override func log(message logMessage: DDLogMessage)
    {
        loggerQueue.async
        {
            [weak self] in

            guard let self = self else { return }

            let _logFilePath: String
            // check log file status
            if LogHelper.shared.shouldCreateNewLogFile()
            {
                guard let logFilePath = LogHelper.shared.createNewLogFile() else
                {
                    return
                }
                _logFilePath = logFilePath
            }
            else
            {
                guard let logFilePath = LogHelper.shared.getNewestFilePath() else
                {
                    return
                }
                _logFilePath = logFilePath
            }

            let prefix = self.modePrefix(logMessage.timestamp, file: logMessage.file, function: logMessage.function, line: logMessage.line)
            let category = logMessage.tag as! String
            let cat = category.isEmpty ? category : category + String.Space
            let itemsString = logMessage.message
            let line = "\(Self.prompt)\(self.getLogLevelName(logMessage.level))\(cat)\(prefix)\(itemsString)"

            Swift.print(line, terminator: Self.terminator)

            // check if minFreeDiskSpaceRequired condition is met
            guard FileManager.default.availableDiskSpaceInMB() > Self.minFreeDiskSpaceRequired else
            {
                if self._fileLoggingEnabled
                {
                    let error = "[ERROR] :Unable to write logs.Disk memory less than \(Log.minFreeDiskSpaceRequired) MB."
                    Swift.print(error, terminator: Self.terminator)
                    _ = LogFile.append(filePath: _logFilePath, content: "\(error)\(Self.terminator)")
                    self._fileLoggingEnabled = false
                }
                return
            }

            _ = LogFile.append(filePath: _logFilePath, content: "\(line)\(Self.terminator)")
        }
    }


    private func modePrefix(_ date: Date, file: String, function: String?, line: UInt) -> String
    {
        var result: String = String.Empty

        // date
        let s = Date.stringFromDate(date, format: "yyyy-MM-dd HH:mm:ss.SSS ")
        result += s

        // file
        result += "\(file.lastPathComponent.stringByDeletingPathExtension)."

        // function
        if let function = function
        {
            result += "\(function)"
        }

        // line
        result += "[\(line)]"

        if !result.isEmpty
        {
            result = result.trimmingCharacters(in: CharacterSet.whitespaces)
            result += ": "
        }

        return result
    }


    private func getLogLevelName(_ level: DDLogLevel) -> String
    {
        switch (level)
        {
            case .all:
                return " [ALL]     "
            case .debug:
                return " [DEBUG]   "
            case .error:
                return " [ERROR]   "
            case .info:
                return " [INFO]    "
            case .off:
                return " [OFF]     "
            case .verbose:
                return " [VERBOSE] "
            case .warning:
                return " [WARNING] "
            @unknown default:
                return " [UNKNOWN] "
        }
    }
}
