//
//  RsyncManager.swift
//  SvijaSync
//
//  Created by Rajesh Ramachandrakurup on 30/1/21.
//

import Foundation

public enum OperationType {
    case checkConnection
    case fetchLastOwner
    case download
    case upload
}

public protocol RsyncManagerInterface {
    func execute(_ operation: OperationType, connection: SiteConnection, callback: @escaping BashCallBack)
    func stop(callback: () -> ())
}

public class RsyncManager: RsyncManagerInterface {

    public static let shared = RsyncManager()


    private lazy var bash: BashExecuter = BashExecuter(successCheck: successCheck)

    public func stop(callback: () -> ()) {
        bash.stop(callback: callback)
    }

    public func execute(_ operation: OperationType, connection: SiteConnection, callback: @escaping BashCallBack) {
        execute(operation.script, args: connection.basicArgs, dirPath: connection.localPath, callback: callback)
    }

    private func execute(_ script: Script, args: [String], dirPath: String, callback: @escaping BashCallBack) {
        bash.execute(script.file, type: script.ext, args: args, dirPath: dirPath, callback: callback)
    }

}

let successCheck = "success"

fileprivate extension SiteConnection {

    // Remote connection, password, success check word
    var basicArgs: [String] { [remoteSyncAddress, password, successCheck] }

}

fileprivate extension OperationType {

    var script: Script {
        var file = ""
        switch self {
        case .checkConnection: file = "check-connection"
        case .fetchLastOwner: file = "last-owner"
        case .download: file = "download"
        case .upload: file = "upload"
        }
        return Script(file: file, ext: "sh")
    }

}

fileprivate struct Script {
    let file: String
    let ext: String
}
