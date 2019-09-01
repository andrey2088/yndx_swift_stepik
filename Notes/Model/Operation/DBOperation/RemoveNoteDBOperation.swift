//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteDBOperation: BaseDBOperation {

    private let note: Note

    init(note: Note, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(context: context, backgroundContext: backgroundContext)
    }

    override func main() {
        print("DB REMOVE started.")

        if let dbNote = self.getDbNoteByNoteUid(noteUid: self.note.uid) {
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                defer { group.leave() }

                guard let `self` = self else { return }

                self.backgroundContext.performAndWait {
                    do {
                        self.backgroundContext.delete(dbNote)
                        try self.backgroundContext.save()
                    } catch {
                        print(error)
                    }
                }
            }
            group.wait()
        }
        
        print("DB REMOVE finished.")
        finish()
    }
}
