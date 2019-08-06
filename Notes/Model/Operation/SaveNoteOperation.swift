//
//  SaveNoteOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class SaveNoteOperation: AsyncOperation {

    private let backendQueue: OperationQueue
    private let dbQueue: OperationQueue

    private let note: Note
    private let saveDb: SaveNoteDBOperation
    private var saveBackend: SaveNotesBackendOperation

    var notebook: FileNotebook
    private(set) var result: Bool? = false

    init(note: Note, notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        self.note = note
        self.notebook = notebook
        self.backendQueue = backendQueue
        self.dbQueue = dbQueue

        saveDb = SaveNoteDBOperation(note: note, notebook: notebook)
        saveBackend = SaveNotesBackendOperation(notebook: notebook)

        super.init()
    }

    override func main() {
        print("OP: Save note started")

        let notebook = self.notebook
        let adapter = BlockOperation() { [unowned saveBackend, unowned notebook] in
            saveBackend.notebook = notebook
        }

        adapter.addDependency(saveDb)
        saveBackend.addDependency(adapter)

        dbQueue.addOperation(saveDb)
        backendQueue.addOperation(adapter)
        backendQueue.addOperation(saveBackend)
        backendQueue.waitUntilAllOperationsAreFinished()

        switch saveBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }

        print("OP: Save note finished")
        finish()
    }
}
