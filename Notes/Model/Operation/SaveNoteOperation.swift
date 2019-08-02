//
//  SaveNoteOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class SaveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let saveDb: SaveNoteDBOperation
    private var saveBackend: SaveNotesBackendOperation

    private(set) var result: Bool? = false

    init(
        note: Note,
        notebook: FileNotebook,
        backendQueue: OperationQueue,
        dbQueue: OperationQueue
    ) {
        self.note = note
        self.notebook = notebook

        saveDb = SaveNoteDBOperation(note: note, notebook: notebook)
        saveBackend = SaveNotesBackendOperation(notes: notebook.notes)

        let adapter = BlockOperation() { [unowned saveBackend] in
            saveBackend.notes = notebook.notes
        }

        super.init()

        adapter.addDependency(saveDb)
        saveBackend.addDependency(adapter)
        addDependency(saveBackend)

        dbQueue.addOperation(saveDb)
        backendQueue.addOperation(adapter)
        backendQueue.addOperation(saveBackend)
    }

    override func main() {
        switch saveBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
