//
//  RemoveNoteOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class RemoveNoteOperation: AsyncOperation {

    private let backendQueue: OperationQueue
    private let dbQueue: OperationQueue

    private let note: Note
    private let removeDb: RemoveNoteDBOperation
    private var saveBackend: SaveNotesBackendOperation

    var notebook: FileNotebook
    private(set) var result: Bool? = false

    init(note: Note, notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        self.note = note
        self.notebook = notebook
        self.backendQueue = backendQueue
        self.dbQueue = dbQueue

        removeDb = RemoveNoteDBOperation(note: note, notebook: notebook)
        saveBackend = SaveNotesBackendOperation(notes: notebook.notes)

        super.init()
    }

    override func main() {
        print("OP: Remove note started")

        let notebook = self.notebook
        let adapter = BlockOperation() { [unowned saveBackend, unowned notebook] in
            saveBackend.notes = notebook.notes
        }

        adapter.addDependency(removeDb)
        saveBackend.addDependency(adapter)
        addDependency(saveBackend)

        dbQueue.addOperation(removeDb)
        backendQueue.addOperation(adapter)
        backendQueue.addOperation(saveBackend)
        backendQueue.waitUntilAllOperationsAreFinished()

        switch saveBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }

        print("OP: Remove note finished")
        finish()
    }
}
