//
//  ColorPickerView.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class ColorPickerView: UIView {

    private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private let sideMargin: CGFloat = 15
    private let cornerRadius: CGFloat = 7

    private let selectedView = UIView()
    let selectedColorView = UIView()
    let selectedHexLabel = UILabel()
    let brightnessSlider = UISlider()
    private let brightnessLabel = UILabel()
    let paletteView = PaletteView(frame: CGRect.zero)
    let doneButton = UIButton()

    private let selectedViewMarginTop: CGFloat = 10
    private let selectedViewMarginRight: CGFloat = 20
    private let brightnessSliderMarginTop: CGFloat = 5
    private let brightnessLabelHeight: CGFloat = 30
    private let paletteViewMarginTop: CGFloat = 10
    private let doneButtonMarginTop: CGFloat = 20
    private let doneButtonMarginBottom: CGFloat = 20


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

        adjustSelectedViewsLayout()
        adjustBrightnessViewsLayout()
        adjustPaletteViewLayout()
        adjustDoneButtonLayout()
    }

    private func setupViews() {
        setupSelectedViews()
        setupBrightnessViews()
        setupPaletteView()
        setupDoneButton()

        self.addSubview(selectedView)
        selectedView.addSubview(selectedColorView)
        selectedView.addSubview(selectedHexLabel)
        self.addSubview(brightnessSlider)
        self.addSubview(brightnessLabel)
        self.addSubview(paletteView)
        self.addSubview(doneButton)
    }


    // ---------- Selected views ----------

    private func adjustSelectedViewsLayout() {
        let selectedColorSide = ((portraitWidth - sideMargin) * 0.24).rounded()
        let selectedHeight = (selectedColorSide * 1.18).rounded()

        selectedView.frame = CGRect(
            x: self.bounds.minX + sideMargin,
            y: self.bounds.minY + selectedViewMarginTop,
            width: selectedColorSide,
            height: selectedHeight
        )

        selectedColorView.frame = CGRect(
            x: selectedView.bounds.minX,
            y: selectedView.bounds.minY,
            width: selectedColorSide,
            height: (selectedColorSide * 0.93).rounded()
        )

        selectedHexLabel.frame = CGRect(
            x: selectedView.bounds.minX,
            y: selectedColorView.bounds.maxY,
            width: selectedColorSide,
            height: selectedHeight - selectedColorSide
        )
    }

    private func setupSelectedViews() {
        selectedView.layer.borderWidth = 1
        selectedView.layer.borderColor = UIColor.black.cgColor
        selectedView.layer.cornerRadius = cornerRadius

        selectedColorView.layer.borderWidth = 1
        selectedColorView.layer.borderColor = UIColor.black.cgColor
        selectedColorView.layer.cornerRadius = cornerRadius
        selectedColorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        selectedHexLabel.textAlignment = .center
    }


    // ---------- Brightness views ----------

    private func adjustBrightnessViewsLayout() {
        brightnessSlider.frame.origin = CGPoint(
            x: selectedView.frame.maxX + selectedViewMarginRight,
            y: selectedView.frame.maxY - brightnessSlider.frame.size.height
        )
        brightnessSlider.frame.size.width =
            self.bounds.size.width - selectedView.frame.maxX - selectedViewMarginRight - sideMargin * 2

        brightnessLabel.frame = CGRect(
            x: selectedView.frame.maxX + selectedViewMarginRight,
            y: selectedView.frame.maxY - brightnessSlider.frame.size.height - brightnessSliderMarginTop
                - brightnessLabelHeight,
            width: self.bounds.size.width - selectedView.frame.maxX - selectedViewMarginRight - sideMargin * 2,
            height: brightnessLabelHeight
        )
    }

    private func setupBrightnessViews() {
        brightnessLabel.text = "Brightness"

        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 1
    }


    // ---------- Palette view ----------

    private func adjustPaletteViewLayout() {
        paletteView.frame = CGRect(
            x: self.bounds.minX + sideMargin,
            y: selectedView.frame.maxY + paletteViewMarginTop,
            width: self.bounds.size.width - sideMargin * 2,
            height: self.bounds.size.height - selectedView.frame.maxY - paletteViewMarginTop
                - doneButtonMarginTop - doneButton.intrinsicContentSize.height - doneButtonMarginBottom
        )
    }

    private func setupPaletteView() {
        paletteView.layer.borderWidth = 1
        paletteView.layer.borderColor = UIColor.black.cgColor
    }

    // ---------- Done button ----------

    private func adjustDoneButtonLayout() {
        doneButton.frame = CGRect(
            x: self.bounds.minX + (self.bounds.size.width - doneButton.intrinsicContentSize.width) / 2,
            y: paletteView.frame.maxY + doneButtonMarginTop,
            width: doneButton.intrinsicContentSize.width,
            height: doneButton.intrinsicContentSize.height
        )
    }

    private func setupDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(doneButton.tintColor, for: .normal)
    }
}
