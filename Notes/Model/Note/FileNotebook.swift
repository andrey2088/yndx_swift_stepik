import UIKit

public class FileNotebook {
    private let dirname: String = "notebook_files"
    private let filename: String = "notes.js"
    public private(set) var notes: [String: Note] = [:]


    public init (/*filename: String*/) {
        //self.filename = filename
        self.loadFromFile()
    }

    // Note with existing id will be replaced
    public func add(_ note: Note) {
        self.notes[note.uid] = note
    }

    public func remove(with uid: String) {
        if (self.notes[uid] == nil) {
            return
        }

        self.notes.removeValue(forKey: uid)
    }


    public func saveToFile() {
        do {
            let jsonData = try self.generateDataForJson()
            let fileUrl = try self.getFileUrl()
            try jsonData.write(to: fileUrl)
        } catch FileNotebookError.cantCreateDir {
            print("Can not create a directory for json file.")
        } catch FileNotebookError.cantGenerateJsonData {
            print("Can not generate json to save to file.")
        } catch{
            print("Unknown error while saving notes to json file.")
        }
    }

    
    public func loadFromFile() {
        self.notes = [:]

        do {
            let fileUrl = try self.getFileUrl()
            if self.isFileExists(fileUrl: fileUrl) {
                let jsonData = try Data(contentsOf: fileUrl)
                try self.fillNotesWithJsonData(jsonData: jsonData)
            }
        } catch FileNotebookError.cantCreateDir {
            print("Can not create a directory for json file.")
        } catch FileNotebookError.jsonWrongFormat {
            print("Wrong data in json file.")
        } catch{
            print("Unknown error while loading notes from json file.")
        }
    }

    
    public func clearFile() {
        self.notes = [:]
        self.saveToFile()
    }


    public func getNotesArraySortedByTitle() -> [Note] {
        var notesArr: [Note] = []

        for note in notes {
            notesArr.append(note.value)
        }

        notesArr.sort(by: { $0.title < $1.title })

        return notesArr
    }


    private func generateDataForJson() throws -> Data {
        var jsonData: Data
        var jsonArr: [[String: Any]] = []

        for note in self.notes {
            jsonArr.append(note.value.json)
        }

        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonArr, options: [])
        } catch {
            throw FileNotebookError.cantGenerateJsonData
        }

        return jsonData
    }


    private func fillNotesWithJsonData(jsonData: Data) throws {
        let jsonArrAny: Any? = try? JSONSerialization.jsonObject(with: jsonData, options: [])

        guard
            let jsonArr: [[String: Any]] = jsonArrAny as? [[String: Any]]
        else {
            throw FileNotebookError.jsonWrongFormat
        }

        for jsonArrNote in jsonArr {
            let note = Note.parse(json: jsonArrNote)
            if (note != nil) {
                self.notes[note!.uid] = note
            }
        }
    }


    private func isFileExists(fileUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }


    private func getFileUrl() throws -> URL {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dirUrl = path.appendingPathComponent(self.dirname)

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
