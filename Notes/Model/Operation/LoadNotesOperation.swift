//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class LoadNotesOperation: AsyncOperation {

    private let backendQueue: OperationQueue
    private let dbQueue: OperationQueue

    private let loadBackend: LoadNotesBackendOperation
    private let loadDb: LoadNotebookDBOperation
    //private var replaceDb: BaseDBOperation = BaseDBOperation()

    var notebook: FileNotebook? = nil
    private(set) var result: Bool? = false

    init(backendQueue: OperationQueue, dbQueue: OperationQueue) {
        self.backendQueue = backendQueue
        self.dbQueue = dbQueue

        loadBackend = LoadNotesBackendOperation()
        loadDb = LoadNotebookDBOperation()

        super.init()
    }

    override func main() {
        print("OP: Load notes started")

        let adapter = BlockOperation() { [unowned loadBackend, unowned loadDb, unowned self] in
            print("Load adapter started.")
            if let backendNotebook = loadBackend.notebook, loadBackend.result! == .success {
                print("Load adapter: backend success.")
                self.notebook = backendNotebook
                self.notebook?.saveToFile()
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

        if let dbNotebook = loadDb.notebook {
            self.notebook = dbNotebook
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
