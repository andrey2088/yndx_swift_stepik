//
//  LoadNotebookDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation
import CoreData

class LoadNotesDBOperation: BaseDBOperation {

    var notes: [Note] = []
    private var dbNotes: [DBNote] = []

    override func main() {
        print("OP: DB load started")
        fetchDbNotes()
        setNotesFromDbNotes()
        
        print("OP: DB load finished")
        finish()
    }

    private func fetchDbNotes() {
        let request: NSFetchRequest<DBNote> = DBNote.fetchRequest()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            defer { group.leave() }

            guard let `self` = self else { return }

            self.backgroundContext.performAndWait {
                do {
                    self.dbNotes = try self.backgroundContext.fetch(request)
                } catch {
                    print(error)
                }
            }
        }
        group.wait()
    }

    private func setNotesFromDbNotes() {
        var notes: [Note] = []

        for dbNote in dbNotes {
            let note = Note(
                uid: dbNote.uid!,
                title: dbNote.title!,
                content: dbNote.content!,
                color: Note.uicolorFromString(dbNote.color!),
                importance: Note.Importance(rawValue: dbNote.importance!) ?? Note.Importance.normal,
                selfDestructDate: dbNote.selfDestructDate
            )
            notes.append(note)
        }

        self.notes = notes
    }
}
