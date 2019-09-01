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
        print("BACK LOAD started.")
        result = .failure(.unreachable)

        loadNotes()
        if let loadedNotes = loadedNotes, let loadedGist = loadedGist {
            notebook = FileNotebook(notes: loadedNotes, gistId: loadedGist.id)
            result = .success
        }

        print("BACK LOAD finished.")
        finish()
    }

    func loadNotes() {
        guard let url = URL(string: remoteLoadAddress) else { return }
        var request = URLRequest(url: url)
        request.setValue("token \(remoteToken)", forHTTPHeaderField: "Authorization")

        let group = DispatchGroup()
        let task = URLSession.shared.dataTask(with: request) { [weak self]
            (data, response, error) in

            defer { group.leave() }

            guard error == nil else {
                print("BACK LOAD error:")
                print(error?.localizedDescription ?? "Unknown error.")
                return
            }

            guard let sself = self, let data = data else { return }

            do {
                let gists = try JSONDecoder().decode([GistLoad].self, from: data)
                try sself.loadNotesFromLoadedGists(gists)
                if (sself.loadedNotes != nil) {
                    print("BACK LOAD success")
                } else {
                    print("BACK LOAD success, but empty")
                }
            } catch {
                print("BACK LOAD error:\n \(error)")
                return
            }
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
