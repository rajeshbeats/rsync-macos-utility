//
//  SiteConnection.swift
//  SvijaSync
//
//  Created by Rajesh Ramachandrakurup on 6/2/21.
//

import Foundation

public struct SiteConnection: Codable {

    public let uuid: String
    public let server: String
    public let username :String
    public let password: String
    public let localPath: String
    public let timestamp: TimeInterval
    public var isDefault: Bool

    public init(
        uuid: String,
        server: String,
        username: String,
        password: String,
        localPath: String,
        timestamp: TimeInterval,
        isDefault: Bool)
    {
        self.uuid = uuid
        self.server = server
        self.username = username
        self.password = password
        self.localPath = localPath
        self.timestamp = timestamp
        self.isDefault = isDefault
    }

}
