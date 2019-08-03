//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class LoadNotesDBOperation: BaseDBOperation {

    init() {
        let notebook = FileNotebook()
        super.init(notebook: notebook)
    }

    override func main() {
        notebook = FileNotebook()
        print("OP: DB load")
        finish()
    }
}
