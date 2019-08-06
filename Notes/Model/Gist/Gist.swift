//
//  Gist.swift
//  Notes
//
//  Created by andrey on 2019-08-06.
//  Copyright © 2019 andrey. All rights reserved.
//

import Foundation

struct GistSave: Codable {
    let files: [String: GistFileSave]
    let publicStatus: Bool

    private enum CodingKeys: String, CodingKey {
        case files
        case publicStatus = "public"
    }
}

struct GistFileSave: Codable {
    let content: String
}


struct GistLoad: Codable {
    let id: String
    let files: [String: GistFileLoad]
}

struct GistFileLoad: Codable {
    let rawUrl: String

    private enum CodingKeys: String, CodingKey {
        case rawUrl = "raw_url"
    }
}
