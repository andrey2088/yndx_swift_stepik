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
    private var replaceDb: BaseDBOperation = BaseDBOperation()

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
            self.notebook = loadDb.notebook

            switch loadBackend.result! {
            case .success:
                self.replaceDb = ReplaceNotesDBOperation(notesToReplace: [:], notebook: self.notebook!)
            case .failure:
                self.replaceDb.cancel()
            }
        }

        loadDb.addDependency(loadBackend)
        adapter.addDependency(loadDb)
        replaceDb.addDependency(adapter)

        backendQueue.addOperation(loadBackend)
        dbQueue.addOperation(loadDb)
        dbQueue.addOperation(adapter)
        dbQueue.addOperation(replaceDb)
        dbQueue.waitUntilAllOperationsAreFinished()

        switch loadBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }

        print("OP: Load notes finished")
        finish()
    }
}
