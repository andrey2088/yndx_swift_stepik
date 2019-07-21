//
//  PhotoNote.swift
//  Notes
//
//  Created by andrey on 2019-07-22.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

struct PhotoNote {
    internal let uid: String
    internal let photo: UIImage

    internal init(photo: UIImage) {
        uid = UUID().uuidString
        self.photo = photo
    }
}

extension PhotoNote {
    static var allPhotoNotes: [PhotoNote] = [
        PhotoNote(photo: UIImage(named: "gallery/1")!),
        PhotoNote(photo: UIImage(named: "gallery/2")!),
        PhotoNote(photo: UIImage(named: "gallery/3")!),
        PhotoNote(photo: UIImage(named: "gallery/4")!),
        PhotoNote(photo: UIImage(named: "gallery/5")!),
        PhotoNote(photo: UIImage(named: "gallery/6")!),
        PhotoNote(photo: UIImage(named: "gallery/7")!),
        PhotoNote(photo: UIImage(named: "gallery/8")!),
    ]
}
