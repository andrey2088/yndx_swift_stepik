//
//  SaveNoteDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {

    private let note: Note

    init(note: Note, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(context: context, backgroundContext: backgroundContext)
    }

    override func main() {
        print("OP: DB save started")

        if let dbNote = getDbNoteByNoteUid(noteUid: note.uid) {
            setDbNoteFromNote(dbNote: dbNote)
        } else {
            let dbNote = DBNote(context: backgroundContext)
            setDbNoteFromNote(dbNote: dbNote)
        }

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            defer { group.leave() }

            guard let `self` = self else { return }

            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch {
                    print(error)
                }
            }
        }
        group.wait()

        print("OP: DB save finished")
        finish()
    }

    private func setDbNoteFromNote(dbNote: DBNote) {
        dbNote.uid = note.uid
        dbNote.title = note.title
        dbNote.content = note.content
        dbNote.color = Note.uicolorToString(note.color)
        dbNote.importance = note.importance.rawValue
        dbNote.selfDestructDate = note.selfDestructDate
    }
}
