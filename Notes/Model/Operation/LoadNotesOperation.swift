//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation
import CoreData

class LoadNotesOperation: AsyncOperation {

    private let backendQueue: OperationQueue
    private let dbQueue: OperationQueue
    private let dbNoteContainer: NSPersistentContainer

    private let loadBackend: LoadNotesBackendOperation
    private let loadDb: LoadNotesDBOperation
    //private var replaceDb: BaseDBOperation = BaseDBOperation()

    var notebook: FileNotebook? = nil
    private(set) var result: Bool? = false

    init(backendQueue: OperationQueue, dbQueue: OperationQueue, dbNoteContainer: NSPersistentContainer) {
        self.backendQueue = backendQueue
        self.dbQueue = dbQueue
        self.dbNoteContainer = dbNoteContainer

        loadBackend = LoadNotesBackendOperation()
        loadDb = LoadNotesDBOperation(
            context: dbNoteContainer.viewContext,
            backgroundContext: dbNoteContainer.newBackgroundContext()
        )

        super.init()
    }

    override func main() {
        print("OP: Load notes started")

        let adapter = BlockOperation() { [unowned loadBackend, unowned loadDb, unowned self] in
            print("Load adapter started.")
            if let backendNotebook = loadBackend.notebook, loadBackend.result! == .success {
                print("Load adapter: backend success.")
                self.notebook = backendNotebook
                //self.notebook?.saveToFile()
                //self.replaceDb =
                //    ReplaceNotesDBOperation(notesToReplace: loadBackend.notebook.notes, notebook: self.notebook!)
                loadDb.cancel()
            }
            print("Load adapter finished.")
        }

        adapter.addDependency(loadBackend)
        loadDb.addDependency(adapter)
        //replaceDb.addDependency(adapter)

        backendQueue.addOperation(loadBackend)
        dbQueue.addOperation(adapter)
        dbQueue.addOperation(loadDb)
        //dbQueue.addOperation(replaceDb)
        dbQueue.waitUntilAllOperationsAreFinished()

        if (!loadDb.isCancelled) {
            let notesArr = loadDb.notes
            let notes = convertArrayToNotes(notesArr: notesArr)
            self.notebook = FileNotebook(notes: notes)
        }

        if (notebook != nil) {
            result = true
        } else {
            result = false
        }

        print("OP: Load notes finished")
        finish()
    }
}
