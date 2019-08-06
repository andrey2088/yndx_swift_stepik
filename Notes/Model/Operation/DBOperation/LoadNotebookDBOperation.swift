//
//  LoadNotebookDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class LoadNotebookDBOperation: BaseDBOperation {

    var notebook: FileNotebook? = nil

    override func main() {
        notebook = FileNotebook()
        if let notebook = notebook {
            notebook.loadFromFile()
        }
        
        print("OP: DB load")
        finish()
    }
}
