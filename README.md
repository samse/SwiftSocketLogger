# SwiftSocketLogger
This is socket logger for ios written with Swift.

It's run on background app in audio playing mode and receive log from other client app.

![socketlogger_screenshot](https://user-images.githubusercontent.com/3222919/176802683-ab00f42f-44d3-481a-bdd8-7d51b429f8ba.jpeg)


Client program can send a log using below code.
- Prerequisists : include all files to your project in swiftsocket directory of this Project.
- files : yudpsocket.c, ytcpsocket.c, TCPClient.swift, Result.swift, SwiftSocket.h, UDPClient.swift, Socket.swift

```

class Logger {
    static func debug(_ message: String?) {
        printLog(level: "🐛 DEBUG", message: message)
    }
    
    /// 경고 로그
    static func warning(_ message: String?) {
        printLog(level: "⚠️ WARNING", message: message)
    }
    
    /// 오류 로그
    static func error(_ message: String?) {
        printLog(level: "🚫 ERROR", message: message)
    }
    
    /// 정보 로그
    static func info(_ message: String?) {
        printLog(level: "ℹ️ INFO", message: message)
    }

    func printLog(level: String, message: String) {
        let logStr = "[\(level)] \(message ?? "")"
        self.appendLog(logStr)
    }
    
    static var logQueue = [String]()
    static let lock = NSLock()
    private static func appendLog(_ logStr: String) {
        print("\(logStr)")
        lock.lock(); defer { lock.unlock() }
        logQueue.append(logStr)
        triggerLogging()
    }
    private static func getLog() -> String? {
        if logQueue.count > 0 {
            return logQueue.first
        }
        return nil
    }
    private static func removeLog() {
        if logQueue.count > 0 {
            logQueue.removeFirst()
        }
    }
    
    static var socketLogger: SocketLogger = SocketLogger()
    private static func triggerLogging() {
        if let logStr = getLog() {
            socketLogger.sendLogs(logStr) {
                removeLog()
                triggerLogging()
            }
        }
    }
}

class SocketLogger : NSObject {
    enum LoggerStatus: Int { case disconnected=0, connecting, connected }
    var status: LoggerStatus = .disconnected

    func sendLogs(_ logStr: String, completion: (() -> ())?) {
        if status == .connected {
            return
        }
        status = .connecting
        print("Logger sendLogs : \(logStr)")
        let client = TCPClient(address: "127.0.0.1", port: 2532)
        switch client.connect(timeout: 10) {
          case .success:
            status = .connected
            let data = logStr.data(using: .utf8)
            let _ = client.send(data: data!)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                self.status = .disconnected
                if let completion = completion { completion() }
            }
          case .failure(let error):
            print("failure: \(error)")
            status = .disconnected
        }
    }
}

```
