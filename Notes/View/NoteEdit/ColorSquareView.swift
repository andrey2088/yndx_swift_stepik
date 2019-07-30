//
//  ColorSquareView.swift
//  Notes
//
//  Created by andrey on 2019-07-30.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class ColorSquareView: UIView {

    var color: UIColor = UIColor.clear {
        didSet {
            backgroundColor = color
        }
    }

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
    }

    func setFrame(x: CGFloat, side: CGFloat) {
        frame = CGRect(
            x: x,
            y: 0,
            width: side,
            height: side
        )
    }

    private func setupViews() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
