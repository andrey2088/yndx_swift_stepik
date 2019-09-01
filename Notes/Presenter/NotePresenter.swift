//
//  NotePresenter.swift
//  Notes
//
//  Created by andrey on 2019-09-01.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit /* because of Note's color property with type UIColor */
import CoreData

protocol NoteEditVCDelegate: NSObjectProtocol {

}

protocol NoteListVCDelegate: NSObjectProtocol {
    func refreshTable()
}


class NotePresenter {

    weak private var noteEditVCDelegate: NoteEditVCDelegate?
    weak private var noteListVCDelegate: NoteListVCDelegate?

    private let backendQueue = OperationQueue()
    private let dbQueue = OperationQueue()
    private let commonQueue = OperationQueue()

    var dbNoteContainer: NSPersistentContainer
    private var fileNotebook: FileNotebook? = nil
    private var notesArr: [Note] = []

    init(dbNoteContainer: NSPersistentContainer) {
        self.dbNoteContainer = dbNoteContainer
    }


    func setNoteEditVCDelegate(_ noteEditVCDelegate: NoteEditVCDelegate) {
        self.noteEditVCDelegate = noteEditVCDelegate
    }

    func setNoteListVCDelegate(_ noteListVCDelegate: NoteListVCDelegate) {
        self.noteListVCDelegate = noteListVCDelegate
    }


    func getNotesCount() -> Int {
        return notesArr.count
    }

    func getNoteUidByIndex(_ noteIndex: Int) -> String {
        return notesArr[noteIndex].uid
    }

    func getNoteTitleByIndex(_ noteIndex: Int) -> String {
        return notesArr[noteIndex].title
    }

    func getNoteContentByIndex(_ noteIndex: Int) -> String {
        return notesArr[noteIndex].content
    }

    func getNoteColorByIndex(_ noteIndex: Int) -> UIColor {
        return notesArr[noteIndex].color
    }

    func getNoteSelfDestructDateByIndex(_ noteIndex: Int) -> Date? {
        return notesArr[noteIndex].selfDestructDate
    }


    func addNote(uid: String, title: String, content: String, color: UIColor, selfDestructDate: Date? = nil) {
        let note = Note(uid: uid, title: title, content: content, color: color, selfDestructDate: selfDestructDate)
        let saveNoteOp = SaveNoteOperation(
            note: note,
            notebook: fileNotebook!,
            backendQueue: backendQueue,
            dbQueue: dbQueue,
            dbNoteContainer: dbNoteContainer
        )
        let handleDataOp = BlockOperation() { [unowned saveNoteOp, unowned self] in
            self.fileNotebook = saveNoteOp.notebook
            self.notesArr = self.convertNotesToArray(notes: self.fileNotebook!.notes)
        }

        handleDataOp.addDependency(saveNoteOp)

        commonQueue.addOperation(saveNoteOp)
        commonQueue.addOperation(handleDataOp)

        refreshTable(dependencyOp: handleDataOp)
    }

    func removeNote(noteIndex: Int) {
        let note = notesArr[noteIndex]

        let removeNoteOp = RemoveNoteOperation(
            note: note,
            notebook: fileNotebook!,
            backendQueue: backendQueue,
            dbQueue: dbQueue,
            dbNoteContainer: dbNoteContainer
        )
        let handleDataOp = BlockOperation() { [unowned removeNoteOp, unowned self] in
            self.fileNotebook = removeNoteOp.notebook
            self.notesArr = self.convertNotesToArray(notes: self.fileNotebook!.notes)
        }

        handleDataOp.addDependency(removeNoteOp)

        commonQueue.addOperation(removeNoteOp)
        commonQueue.addOperation(handleDataOp)

        refreshTable(dependencyOp: handleDataOp)
    }

    func loadNotes() {
        let loadNotesOp = LoadNotesOperation(
            backendQueue: backendQueue,
            dbQueue: dbQueue,
            dbNoteContainer: dbNoteContainer
        )
        let handleDataOp = BlockOperation() { [unowned loadNotesOp, unowned self] in
            self.fileNotebook = loadNotesOp.notebook!
            self.notesArr = self.convertNotesToArray(notes: self.fileNotebook!.notes)
        }

        handleDataOp.addDependency(loadNotesOp)

        commonQueue.addOperation(loadNotesOp)
        commonQueue.addOperation(handleDataOp)

        refreshTable(dependencyOp: handleDataOp)
    }


    
    private func refreshTable(dependencyOp: Operation) {
        let refreshTableOp = BlockOperation() { [weak noteListVCDelegate] in
            noteListVCDelegate?.refreshTable()
        }

        refreshTableOp.addDependency(dependencyOp)
        OperationQueue.main.addOperation(refreshTableOp)
    }

    private func convertNotesToArray(notes: [String: Note]) -> [Note] {
        var notesArr: [Note] = []

        for note in notes {
            notesArr.append(note.value)
        }

        notesArr.sort(by: { $0.title < $1.title })

        return notesArr
    }
}
