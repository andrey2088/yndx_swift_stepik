//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class RemoveNoteDBOperation: BaseDBOperation {

    private let notebook: FileNotebook
    private let note: Note

    init(note: Note, notebook: FileNotebook) {
        self.notebook = notebook
        self.note = note
        super.init()
    }

    override func main() {
        notebook.remove(with: note.uid)
        notebook.saveToFile()
        
        print("OP: DB remove")
        finish()
    }
}
