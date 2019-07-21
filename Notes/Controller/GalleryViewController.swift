//
//  GalleryViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    //private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private let marginSide: CGFloat = 10
    private let spacing: CGFloat = 10
    //private let columnsCount: Int = 3
    private let photoSide = floor((/*portraitWidth*/ UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
        - /*marginSide*/10 * 2 - /*spacing*/10 * 2) / /*columnsCount*/3)
    
    private let galleryView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var photoNotes: [PhotoNote] = PhotoNote.allPhotoNotes

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustLayouts()
    }

    private func setupViews() {
        title = "Gallery"
        view.backgroundColor = UIColor.white

        galleryView.backgroundColor = UIColor.white
        galleryView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        galleryView.delegate = self
        galleryView.dataSource = self
        galleryView.contentInset =
            UIEdgeInsets(top: marginSide, left: marginSide, bottom: marginSide, right: marginSide)
        self.view.addSubview(galleryView)
    }

    private func adjustLayouts() {
        galleryView.frame = view.safeAreaLayoutGuide.layoutFrame
    }
}


extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoNotes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionCell",
            for: indexPath as IndexPath
        )

        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: photoSide, height: photoSide));
        let photoNote = photoNotes[indexPath.item]
        imageView.image = photoNote.photo
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.cgColor

        cell.contentView.addSubview(imageView)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(width: photoSide, height: photoSide)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
