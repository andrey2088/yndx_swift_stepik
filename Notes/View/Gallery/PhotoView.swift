//
//  PhotoView.swift
//  Notes
//
//  Created by andrey on 2019-07-22.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class PhotoView: UIScrollView {

    private var photoNotes: [PhotoNote] = PhotoNote.allPhotoNotes
    private var imageViews = [UIImageView]()
    var pageSelected: Int = 0
    private var transition: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustLayouts()
    }

    func viewWillTransition() {
        transition = true
    }

    private func setupViews() {
        for photoNote in photoNotes {
            let image = photoNote.photo
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
            self.addSubview(imageView)
        }
    }

    private func adjustLayouts() {
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = self.frame.size
            imageView.frame.origin.x = self.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }
        self.contentSize = CGSize (
            width: self.frame.width * CGFloat(imageViews.count),
            height: self.frame.height
        )
        self.isPagingEnabled = true

        correctContentOffset()
        updateSelectedPageIfChanged()
    }

    private func correctContentOffset() {
        if (transition) {
            self.contentOffset.x = imageViews[pageSelected].frame.minX
            transition = false
        }
    }

    private func updateSelectedPageIfChanged() {
        let offsetDivideByWidth = self.contentOffset.x / self.frame.width
        if (floor(offsetDivideByWidth) == offsetDivideByWidth) {
            pageSelected = Int(offsetDivideByWidth)
        }
    }
}
