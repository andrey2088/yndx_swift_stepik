//
//  SaveNoteDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class SaveNoteDBOperation: BaseDBOperation {
    
    private let note: Note

    init(note: Note, notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }

    override func main() {
        notebook.add(note)
        notebook.saveToFile()
        print("DB save note")
        finish()
    }
}
