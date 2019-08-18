//
//  AsyncOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    private var _executing = false
    private var _finished = false

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return _executing
    }
    override var isFinished: Bool {
        return _finished
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        
        willChangeValue(forKey: "isExecuting")
        _executing = true
        didChangeValue(forKey: "isExecuting")

        main()
    }

    override func main() {
        fatalError("Should be overriden")
    }

    func finish() {
        willChangeValue(forKey: "isFinished")
        _finished = true
        didChangeValue(forKey: "isFinished")
    }

    override func cancel() {
        super.cancel()
        finish()
    }

    
    func convertArrayToNotes(notesArr: [Note]) -> [String: Note] {
        var notes: [String: Note] = [:]

        for note in notesArr {
            notes[note.uid] = note
        }

        return notes
    }
}
