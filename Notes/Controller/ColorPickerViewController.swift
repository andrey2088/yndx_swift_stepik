//
//  ColorPickerViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    private let colorPickerView = ColorPickerView()

    private var pickedColor: UIColor = UIColor.white {
        didSet {
            updateSelectedColor()
        }
    }

    internal var onDoneButtonTapped: ((_ color: UIColor) -> ())?

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustLayouts()
    }

    override internal func viewWillAppear(_ animated: Bool) {
        if (self.isMovingToParent) {
            self.navigationController?.isNavigationBarHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParent) {
            self.navigationController?.isNavigationBarHidden = false
        }
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(colorPickerView)

        brightnessSliderChange()
        doneButtonTap()

        colorPickerView.paletteView.onColorDidChange = { [weak self] color in DispatchQueue.main.async {
            self?.pickedColor = color
        }}
    }

    private func adjustLayouts() {
        colorPickerView.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    private func updateSelectedColor() {
        let selectedColor: UIColor =
            pickedColor.getThisColorWithBrightness(CGFloat(colorPickerView.brightnessSlider.value))
        let selectedHex: String = selectedColor.toHexString()
        colorPickerView.selectedColorView.backgroundColor = selectedColor
        colorPickerView.selectedHexLabel.text = selectedHex
    }


    // ---------- Brightness slider change ----------

    private func brightnessSliderChange() {
        colorPickerView.brightnessSlider.addTarget(self, action: #selector(brightnessSliderChanged), for: UIControl.Event.valueChanged)
    }

    @objc private func brightnessSliderChanged() {
        updateSelectedColor()
    }


    // ---------- Done button tap ----------

    private func doneButtonTap() {
        let doneButtonTap = UITapGestureRecognizer(target: self, action: #selector (doneButtonTapped))
        colorPickerView.doneButton.addGestureRecognizer(doneButtonTap)
    }

    @objc private func doneButtonTapped() {
        let color: UIColor = pickedColor.getThisColorWithBrightness(CGFloat(colorPickerView.brightnessSlider.value))
        self.onDoneButtonTapped?(color)
        self.navigationController?.popViewController(animated: false)
    }
}
