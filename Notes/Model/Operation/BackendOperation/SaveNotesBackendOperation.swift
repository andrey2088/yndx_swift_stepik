//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    
    var result: SaveNotesBackendResult?
    var remoteSaveAddress: String = "https://api.github.com/gists"
    let createMethod: String = "POST"
    let updateMethod: String = "PATCH"

    init(notebook: FileNotebook) {
        super.init()
        self.notebook = notebook
    }

    override func main() {
        result = .failure(.unreachable)

        if let notebook = notebook {
            if let gistId = notebook.gistId {
                saveGist(with: gistId)
            } else {
                saveGist()
            }
        }

        print("OP: Backend save")
        finish()
    }


    private func saveGist(with gistId: String? = nil) {
        var httpMethod: String = ""
        if let gistId = gistId {
            remoteSaveAddress = remoteSaveAddress + "/" + gistId
            httpMethod = updateMethod
        } else {
            httpMethod = createMethod
        }

        guard let url = URL(string: remoteSaveAddress) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        do {
            request.httpBody = try JSONEncoder().encode(buildGistSave())
        } catch {
            print(error)
        }
        request.setValue("token \(remoteToken)", forHTTPHeaderField: "Authorization")

        let group = DispatchGroup()
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let sself = self else { return }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    if (gistId != nil) {
                        print("Backend save (edit) - success")
                    } else {
                        print("Backend save (create) - success")
                    }
                default:
                    print("Backend save error.\nStatus: \(response.statusCode): \(response.description)")
                    return
                }
            }

            if (gistId == nil) {
                if let data = data {
                    do {
                        let gist = try JSONDecoder().decode(GistLoad.self, from: data)
                        sself.notebook!.gistId = gist.id
                    } catch {
                        print("Error while trying to read response: \(error)")
                        return
                    }
                }
            }

            sself.result = .success
            group.leave()
        }

        group.enter()
        task.resume()
        group.wait()
    }


    private func buildGistSave() throws -> GistSave {
        let jsonData: Data = try JSONEncoder().encode(notebook!.notes)
        let jsonString: String? = String(data: jsonData, encoding: .utf8)

        let gistSave = GistSave(
            files: [
                remoteFilename: GistFileSave(content: jsonString!)
            ],
            publicStatus: true
        )

        return gistSave
    }
}
