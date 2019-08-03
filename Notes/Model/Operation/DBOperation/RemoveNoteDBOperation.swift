//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class RemoveNoteDBOperation: BaseDBOperation {

    private let note: Note

    init(note: Note, notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }

    override func main() {
        notebook.remove(with: note.uid)
        //notebook.saveToFile()
        print("OP: DB remove")
        finish()
    }
}
