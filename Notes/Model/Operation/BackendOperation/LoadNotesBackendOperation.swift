//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Created by andrey on 2019-07-31.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

enum LoadNotesBackendResult: Equatable {
    case success
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {

    var result: LoadNotesBackendResult?

    var loadedGist: GistLoad? = nil
    var loadedNotes: [String: Note]? = nil

    override func main() {
        print("OP: Backend load started.")
        result = .failure(.unreachable)

        loadNotes()
        if let loadedNotes = loadedNotes, let loadedGist = loadedGist {
            notebook = FileNotebook(notes: loadedNotes, gistId: loadedGist.id)
            result = .success
        }

        print("OP: Backend load finished.")
        finish()
    }

    func loadNotes() {
        guard let url = URL(string: remoteLoadAddress) else { return }
        var request = URLRequest(url: url)
        request.setValue("token \(remoteToken)", forHTTPHeaderField: "Authorization")

        let group = DispatchGroup()
        let task = URLSession.shared.dataTask(with: request) { [weak self]
            (data, response, error) in

            guard error == nil else {
                print("Backend load error:")
                print(error?.localizedDescription ?? "Unknown error.")
                return
            }

            guard let sself = self, let data = data else { return }

            do {
                let gists = try JSONDecoder().decode([GistLoad].self, from: data)
                try sself.loadNotesFromLoadedGists(gists)
                if (sself.loadedNotes != nil) {
                    print("Backend load - success")
                } else {
                    print("Backend load - success, but empty")
                }
            } catch {
                print("Backend load error:\n \(error)")
                return
            }
            
            group.leave()
        }

        group.enter()
        task.resume()
        group.wait()
    }

    private func loadNotesFromLoadedGists(_ gists: [GistLoad]) throws {
        for gist in gists {
            for file in gist.files {
                if (file.key == remoteFilename) {
                    let fileUrlString = file.value.rawUrl
                    guard let url = URL(string: fileUrlString) else { return }
                    let notesData = try Data(contentsOf: url)
                    loadedNotes = try JSONDecoder().decode([String: Note].self, from: notesData)
                    loadedGist = gist
                    return
                }
            }
        }
    }
}
