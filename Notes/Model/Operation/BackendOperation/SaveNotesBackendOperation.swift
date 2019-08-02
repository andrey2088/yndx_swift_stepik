//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    var notes: [String: Note]

    init(notes: [String: Note]) {
        self.notes = notes
        super.init()
    }

    override func main() {
        result = .failure(.unreachable)
        print("Backend save")
        finish()
    }
}
