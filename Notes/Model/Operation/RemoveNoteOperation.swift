//
//  RemoveNoteOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteOperation: AsyncOperation {

    private let backendQueue: OperationQueue
    private let dbQueue: OperationQueue
    private let dbNoteContainer: NSPersistentContainer

    private let note: Note
    private let removeDb: RemoveNoteDBOperation
    private var saveBackend: SaveNotesBackendOperation

    var notebook: FileNotebook
    private(set) var result: Bool? = false

    init(
        note: Note,
        notebook: FileNotebook,
        backendQueue: OperationQueue,
        dbQueue: OperationQueue,
        dbNoteContainer: NSPersistentContainer
    ) {
        self.note = note
        self.notebook = notebook
        self.backendQueue = backendQueue
        self.dbQueue = dbQueue
        self.dbNoteContainer = dbNoteContainer

        removeDb = RemoveNoteDBOperation(
            note: note,
            context: dbNoteContainer.viewContext,
            backgroundContext: dbNoteContainer.newBackgroundContext()
        )
        saveBackend = SaveNotesBackendOperation(notebook: notebook)

        super.init()
    }

    override func main() {
        print("REMOVE started.")

        notebook.remove(with: note.uid)
        let notebook = self.notebook
        let adapter = BlockOperation() { [unowned saveBackend, unowned notebook] in
            saveBackend.notebook = notebook
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

        print("REMOVE finished.")
        finish()
    }
}
