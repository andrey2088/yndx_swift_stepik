//
//  BaseDBOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class BaseDBOperation: AsyncOperation {
    
    var notebook: FileNotebook

    init(notebook: FileNotebook) {
        self.notebook = notebook
        super.init()
    }
}
