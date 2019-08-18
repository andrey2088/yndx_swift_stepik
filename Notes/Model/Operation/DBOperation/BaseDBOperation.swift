//
//  BaseDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation
import CoreData

class BaseDBOperation: AsyncOperation {

    var context: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext

    init(context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.context = context
        self.backgroundContext = backgroundContext
    }

    func getDbNoteByNoteUid(noteUid: String) -> DBNote? {
        var dbNotes: [DBNote] = []

        let request: NSFetchRequest<DBNote> = DBNote.fetchRequest()
        request.predicate = NSPredicate(format: "uid = '\(noteUid)'")
        request.fetchLimit = 1

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            defer { group.leave() }

            guard let `self` = self else { return }

            self.backgroundContext.performAndWait {
                do {
                    dbNotes = try self.backgroundContext.fetch(request)
                } catch {
                    print(error)
                }
            }
        }
        group.wait()

        if (!dbNotes.isEmpty) {
            return dbNotes[0]
        } else {
            return nil
        }
    }
}
