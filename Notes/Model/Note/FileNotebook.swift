import UIKit

public class FileNotebook {

    private let localAddress: String = "notebook_files"
    var gistId: String? = nil
    private let filename: String = "ios-course-notes-db"

    public private(set) var notes: [String: Note] = [:]


    public init() {}

    init(notes: [String: Note], gistId: String? = nil) {
        self.notes = notes
        if let gistId = gistId {
            self.gistId = gistId
        }
    }


    public func add(_ note: Note) {
        self.notes[note.uid] = note
    }

    public func remove(with uid: String) {
        if (self.notes[uid] == nil) {
            return
        }

        self.notes.removeValue(forKey: uid)
    }

    /*public func replace(_ notes: [String: Note]) {
        self.notes = notes
    }*/


    public func saveToFile() {
        do {
            //let jsonData = try self.toJsonData()
            let jsonData = try JSONEncoder().encode(notes)
            let fileUrl = try self.getFileUrl()
            try jsonData.write(to: fileUrl)
        } catch {
            print("Error while saving notes to json file:\n \(error)")
        }
    }

    
    public func loadFromFile() {
        self.notes = [:]

        do {
            let fileUrl = try self.getFileUrl()
            if self.isFileExists(fileUrl: fileUrl) {
                let jsonData = try Data(contentsOf: fileUrl)
                //try self.loadFromJsonData(jsonData: jsonData)
                notes = try JSONDecoder().decode([String: Note].self, from: jsonData)
            }
        } catch {
            print("Error while loading notes from json file:\n \(error)")
        }
    }

    
    public func clearFile() {
        self.notes = [:]
        self.saveToFile()
    }


    private func isFileExists(fileUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }


    private func getFileUrl() throws -> URL {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dirUrl = path.appendingPathComponent(self.localAddress)

        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: dirUrl.path, isDirectory: &isDir)

        if !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw FileNotebookError.cantCreateDir
            }
        }

        return dirUrl.appendingPathComponent(self.filename)
    }


    private enum FileNotebookError: Error {
        case cantCreateDir
        case cantGenerateJsonData
        case jsonWrongFormat
    }
}
