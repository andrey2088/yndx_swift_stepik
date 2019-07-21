//
//  NoteEditScrollView.swift
//  Notes
//
//  Created by andrey on 2019-07-21.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class NoteEditScrollView: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        self.contentSize.width = self.bounds.width
    }

    private func setupViews() {
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
    }
}
