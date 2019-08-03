//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class LoadNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let loadBackend: LoadNotesBackendOperation
    private let loadDb: LoadNotesDBOperation
    private let replaceDb: ReplaceNotesDBOperation
    var notes: [String: Note] = [:]

    private(set) var result: Bool? = false

    init(
        note: Note,
        notebook: FileNotebook,
        backendQueue: OperationQueue,
        dbQueue: OperationQueue
        ) {
        self.note = note
        self.notebook = notebook

        loadBackend = LoadNotesBackendOperation()
        loadDb = LoadNotesDBOperation()
        replaceDb = ReplaceNotesDBOperation(notesToReplace: [:], notebook: notebook)

        super.init()

        let adapter = BlockOperation() { [unowned loadBackend, unowned loadDb, unowned replaceDb, unowned self] in
            if (loadBackend.result == LoadNotesBackendResult.success) {
                loadDb.cancel()
                replaceDb.notesToReplace = loadBackend.notes
                self.addDependency(replaceDb)
            } else {
                replaceDb.cancel()
                self.addDependency(loadDb)
            }
        }

        adapter.addDependency(loadBackend)
        loadDb.addDependency(adapter)
        replaceDb.addDependency(adapter)

        backendQueue.addOperation(loadBackend)
        dbQueue.addOperation(adapter)
        dbQueue.addOperation(loadDb)
        dbQueue.addOperation(replaceDb)
    }

    override func main() {
        print("OP: Load notes")
        switch loadBackend.result! {
        case .success:
            result = true
            notes = loadBackend.notes
        case .failure:
            result = false
            notes = loadDb.notebook.notes
        }
        finish()
    }
}
