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
    private let syncQueue = OperationQueue()
    private let dbNoteContainer: NSPersistentContainer

    private let loadBackend: LoadNotesBackendOperation
    private let loadDb: LoadNotesDBOperation

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
        print("LOAD started.")

        let syncOp = BlockOperation() { [unowned loadBackend, unowned loadDb, unowned self] in
            print("LOAD sync started.")
            if
                let backendNotebook = loadBackend.notebook,
                loadBackend.result! == .success
            {
                print("LOAD sync: backend success.")
                var dbOps: [Int: BaseDBOperation] = [:]
                var backendNeedsUpdate: Bool = false

                let dbNotesArr = loadDb.notes
                let dbNotes = self.getNotesFromArray(dbNotesArr)
                for backendNotePair in backendNotebook.notes {
                    let backendNote = backendNotePair.value
                    if let dbNote = dbNotes[backendNotePair.key] {
                        if backendNote.modified > dbNote.modified {
                            let removeDb = RemoveNoteDBOperation(
                                note: dbNote,
                                context: self.dbNoteContainer.viewContext,
                                backgroundContext: self.dbNoteContainer.newBackgroundContext()
                            )
                            let saveDB = SaveNoteDBOperation(
                                note: backendNote,
                                context: self.dbNoteContainer.viewContext,
                                backgroundContext: self.dbNoteContainer.newBackgroundContext()
                            )
                            dbOps[dbOps.count + 1] = removeDb
                            dbOps[dbOps.count + 1] = saveDB
                        } else if dbNote.modified > backendNote.modified {
                            backendNotebook.add(dbNote)
                            backendNeedsUpdate = true
                            print("bnu 1")
                        }
                    } else {
                        let saveDB = SaveNoteDBOperation(
                            note: backendNote,
                            context: self.dbNoteContainer.viewContext,
                            backgroundContext: self.dbNoteContainer.newBackgroundContext()
                        )
                        dbOps[dbOps.count + 1] = saveDB
                    }
                }

                for dbNotePair in dbNotes {
                    if backendNotebook.notes[dbNotePair.key] == nil {
                        backendNotebook.add(dbNotePair.value)
                        backendNeedsUpdate = true
                        print("bnu 2")
                    }
                }

                // Self destructing
                for notePair in backendNotebook.notes {
                    let note = notePair.value
                    if
                        let selfDestructDate = note.selfDestructDate,
                        selfDestructDate < Date()
                    {
                        backendNotebook.remove(with: note.uid)
                        backendNeedsUpdate = true
                        
                        let removeDb = RemoveNoteDBOperation(
                            note: note,
                            context: self.dbNoteContainer.viewContext,
                            backgroundContext: self.dbNoteContainer.newBackgroundContext()
                        )
                        dbOps[dbOps.count + 1] = removeDb
                    }

                }

                self.notebook = backendNotebook
                if backendNeedsUpdate {
                    print("LOAD sync: backend needs update.")
                    let saveBackend = SaveNotesBackendOperation(notebook: backendNotebook)
                    self.backendQueue.addOperation(saveBackend)
                }

                if !dbOps.isEmpty {
                    print("LOAD sync: DB needs update.")
                    for dbOpPair in dbOps {
                        if
                            let previousDbOp = dbOps[dbOpPair.key - 1],
                            (dbOpPair.key > 0)
                        {
                            dbOpPair.value.addDependency(previousDbOp)
                        }
                        self.dbQueue.addOperation(dbOpPair.value)
                    }
                }
            } else {
                print("LOAD sync: backend failed.")
                let notes = self.getNotesFromArray(loadDb.notes)
                self.notebook = FileNotebook(notes: notes)
            }
            print("LOAD sync finished.")
        }

        syncOp.addDependency(loadBackend)
        syncOp.addDependency(loadDb)

        backendQueue.addOperation(loadBackend)
        dbQueue.addOperation(loadDb)
        syncQueue.addOperation(syncOp)
        syncQueue.waitUntilAllOperationsAreFinished()

        print("LOAD finished.")
        finish()
    }

    private func getNotesFromArray(_ notesArr: [Note]) -> [String: Note] {
        var notes: [String: Note] = [:]

        for note in notesArr {
            notes[note.uid] = note
        }

        return notes
    }
}
