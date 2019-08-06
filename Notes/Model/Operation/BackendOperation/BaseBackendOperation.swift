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
    let remoteToken: String = "e43ddbd28f31aff4435d0a08f62626b30aa7ee1b"
    let remoteLoadAddress: String
    let remoteFilename: String = "ios-course-notes-db.json"

    var notebook: FileNotebook? = nil

    override init() {
        remoteLoadAddress = "https://api.github.com/users/" + self.remoteLogin + "/gists"
        super.init()
    }
}
