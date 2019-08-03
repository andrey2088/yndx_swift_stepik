//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

enum LoadNotesBackendResult: Equatable {
    case success
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {

    var result: LoadNotesBackendResult?
    var notes: [String: Note] = [:]

    override func main() {
        result = .failure(.unreachable)
        print("OP: Backend load")
        finish()
    }
}
