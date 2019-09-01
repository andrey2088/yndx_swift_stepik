//
//  BaseBackendOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

enum NetworkError {
    case unreachable
}

class BaseBackendOperation: AsyncOperation {

    let remoteLogin: String = "andrey2088"
    let remoteToken: String = "9c66f644201cca83534bf6da1084de9a513b6694"
    let remoteLoadAddress: String
    let remoteFilename: String = "ios-course-notes-db"
    let remoteFilePublicStatus = true

    var notebook: FileNotebook? = nil

    override init() {
        remoteLoadAddress = "https://api.github.com/users/" + self.remoteLogin + "/gists"
        super.init()
    }
}
