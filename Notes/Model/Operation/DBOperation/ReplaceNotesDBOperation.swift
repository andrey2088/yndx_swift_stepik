//
//  ReplaceNotesDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-08-02.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class ReplaceNotesDBOperation: BaseDBOperation {

    var notesToReplace: [String: Note]

    init(notesToReplace: [String: Note], notebook: FileNotebook) {
        self.notesToReplace = notesToReplace
        super.init(notebook: FileNotebook())
    }

    override func main() {
        notebook.replace(notesToReplace)
        print("DB replace all notes")
        finish()
    }
}
