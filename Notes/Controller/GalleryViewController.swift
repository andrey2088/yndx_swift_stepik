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

    var imagePicker = UIImagePickerController()

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

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(plusTapped(_:))
        )

        galleryView.backgroundColor = UIColor.white
        galleryView.register(GalleryCell.self, forCellWithReuseIdentifier: "collectionCell")
        galleryView.delegate = self
        galleryView.dataSource = self
        galleryView.contentInset =
            UIEdgeInsets(top: marginSide, left: marginSide, bottom: marginSide, right: marginSide)
        view.addSubview(galleryView)
    }

    private func adjustLayouts() {
        galleryView.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    private func refreshGallery() {
        photoNotes = PhotoNote.allPhotoNotes
        galleryView.reloadData()
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
        ) as! GalleryCell

        cell.imageView.frame = CGRect(x: 0, y: 0, width: photoSide, height: photoSide)
        let photoNote = photoNotes[indexPath.item]
        cell.imageView.image = photoNote.photo

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewController = PhotoViewController()
        photoViewController.setCurrentPhoto(index: indexPath.item)
        navigationController?.pushViewController(photoViewController, animated: true)
    }
}


extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc private func plusTapped(_ sender: UIButton)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }

        self.present(alert, animated: true, completion: nil)
    }

    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            PhotoNote.allPhotoNotes.append(PhotoNote(photo: image))
            refreshGallery()
        }

        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}



class GalleryCell: UICollectionViewCell {

    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    private func setupViews() {
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
}
