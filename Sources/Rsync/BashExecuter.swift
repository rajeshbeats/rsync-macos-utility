//
//  BashExecuter.swift
//  SvijaSync
//
//  Created by Rajesh Ramachandrakurup on 6/2/21.
//

import Foundation

public enum BashError: Error {
    case alreadyRunning
    case unableToRun
    case unknown
}

public typealias BashCallBack = (Result<Bool, BashError>) -> ()

public class BashExecuter {

    private var fileHandlerObserver: NSObjectProtocol?
    private var terminationObserver: NSObjectProtocol?
    private var termination = false

    private var currentProcess: Process?
    private let successCheck: String
    private var output: String?
    private var taskQueue: DispatchQueue?


    init(successCheck: String) {
        self.successCheck = successCheck
    }

    func stop(callback: () -> ()) {
        debugPrint("♻️ BashExecuter: Current Process force terminating")
        if (currentProcess?.isRunning ?? false) {
            currentProcess?.terminate()
            clearObserver()
        }
        callback()
    }
    
    func execute(_ file: String, type: String, args: [String], dirPath: String, callback: @escaping BashCallBack) {
        guard !(currentProcess?.isRunning ?? false) else {
            debugPrint("♻️ BashExecuter: Current Process already running")
            callback(.failure(.alreadyRunning))
            return
        }
        taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        taskQueue?.async { [weak self] in
            guard let self = self else { return }
            debugPrint("♻️ BashExecuter: Process preparing")
            self.output = nil
            let task = Process()
            self.currentProcess = task
            task.launchPath = Bundle.module.path(forResource: file, ofType: type)
            task.currentDirectoryPath = dirPath
            task.arguments = args

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            let outHandle = pipe.fileHandleForReading
            outHandle.waitForDataInBackgroundAndNotify()

            self.fileHandlerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: nil) {  [weak self] _ in
                let data = outHandle.availableData
                guard data.count > 0 else {
                    return
                }
                self?.output = String(data: data, encoding: .utf8)
                debugPrint("♻️ BashExecuter: Process output: \(self?.output ?? "")")
            }


            self.terminationObserver = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: nil, queue: nil) { [weak self] info in
                guard let self = self else { return }
                debugPrint("♻️ BashExecuter: Process terminated with status: \(task.terminationStatus)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    outHandle.closeFile()
                    self.clearObserver()
                    if self.output?.trimmingCharacters(in: .whitespacesAndNewlines) == self.successCheck {
                        callback(.success(true))
                    } else {
                        debugPrint("♻️⚠️ BashExecuter: Success Check failed - \(self.output ?? "")")
                        debugPrint("♻️⚠️ BashExecuter: info - \(info)")
                        callback(.failure(.unknown))
                    }
                }
            }

            do {
                debugPrint("♻️ BashExecuter: Process starting")
                try task.run()
                task.waitUntilExit()
            } catch let error {
                debugPrint("♻️ BashExecuter: Error running Process - \(error)")
                DispatchQueue.main.async {
                    callback(.failure(.unableToRun))
                }
            }
        }
    }

    private func clearObserver() {
        termination = true
        NotificationCenter.default.removeObserver(fileHandlerObserver as Any)
        NotificationCenter.default.removeObserver(terminationObserver as Any)
        terminationObserver = nil
        terminationObserver = nil
        taskQueue = nil
    }
    
}
