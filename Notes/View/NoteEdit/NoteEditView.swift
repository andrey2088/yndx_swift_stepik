//
//  NoteEditView.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class NoteEditView: UIView {

    private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private let sideMargin: CGFloat = 15

    internal let noteUidView = UITextField()
    internal let noteTitleView = UITextField()
    internal let noteTextView = UITextView()
    private let switchLabelView = UILabel()
    internal let switchView = UISwitch()
    internal let dateView = UIDatePicker()
    private let colorsView = UIView()
    internal let whiteColorSquare = UIView()
    internal let redColorSquare = UIView()
    internal let greenColorSquare = UIView()
    internal let customColorSquare = UIView()
    internal let paletteSquare = UIImageView()
    internal var selectedColorSquare = UIView()
    private let markView = MarkView(frame: CGRect.zero)

    private let noteTitleViewMarginTop: CGFloat = 20
    private let noteTextViewMarginTop: CGFloat = 5
    private let switchLabelViewMarginTop: CGFloat = 0
    private let switchViewMarginTop: CGFloat = 0
    private let dateViewMarginTop: CGFloat = 0
    private let colorsViewMarginTop: CGFloat = 10
    private var colorsViewMarginLeft: CGFloat = 0

    internal var colorPickerView = ColorPickerView(frame: CGRect.zero)
    

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
        updateUI()
    }

    private func setupViews() {
        selectedColorSquare = whiteColorSquare

        setupNoteUidView()
        setupNoteTitleView()
        setupNoteTextView()
        setupSwitchLabelView()
        setupSwitchView()
        setupDateView()
        setupColorsViews()
        setupMarkView()

        self.addSubview(noteTitleView)
        self.addSubview(noteTextView)
        self.addSubview(switchLabelView)
        self.addSubview(switchView)
        self.addSubview(dateView)
        self.addSubview(colorsView)
    }

    internal func updateUI() {
        adjustNoteTitleViewLayout()
        adjustNoteTextViewLayout()
        adjustSwitchLabelViewLayout()
        adjustSwitchViewLayout()
        adjustDateViewLayout()
        adjustColorsViewsLayout()
        adjustMarkViewLayout()

        setViewHeight()
    }

    // ---------- Note uid view ----------

    private func setupNoteUidView() {
        noteUidView.isHidden = true
    }


    // ---------- Note title view ----------

    private func adjustNoteTitleViewLayout() {
        noteTitleView.frame = CGRect(
            x: self.bounds.minX + sideMargin,
            y: self.bounds.minY + noteTitleViewMarginTop,
            width: self.bounds.size.width - sideMargin * 2,
            height: 30
        )
    }

    private func setupNoteTitleView() {
        noteTitleView.layer.cornerRadius = 3
        noteTitleView.layer.borderWidth = 1
        noteTitleView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0.1, alpha: 0.22).cgColor

        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        noteTitleView.leftView = paddingView
        noteTitleView.leftViewMode = .always

        //noteTitleView.font = .systemFont(ofSize: 14)
        noteTitleView.placeholder = "Enter title for your note"
    }


    // ---------- Note text view ----------

    private func adjustNoteTextViewLayout() {
        noteTextView.frame.origin = CGPoint(
            x: self.bounds.minX + sideMargin,
            y: noteTitleView.frame.maxY + noteTextViewMarginTop
        )
        adjustNoteTextViewSize()
    }

    private func setupNoteTextView() {
        noteTextView.delegate = self
        //noteTextView.font = .systemFont(ofSize: 14)
        noteTextView.isScrollEnabled = false
    }


    // ---------- Switch label view ----------

    private func adjustSwitchLabelViewLayout() {
        switchLabelView.frame.origin = CGPoint(
            x: self.bounds.minX + sideMargin,
            y: noteTextView.frame.maxY + switchLabelViewMarginTop
        )

        let switchLabelViewHeight: CGFloat = 30
        let switchLabelViewFitsSize = switchLabelView.sizeThatFits(CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: switchLabelViewHeight
        ))
        switchLabelView.frame.size = CGSize(
            width: switchLabelViewFitsSize.width,
            height: switchLabelViewHeight
        )
    }

    private func setupSwitchLabelView() {
        //switchLabelView.font = .systemFont(ofSize: 16)
        switchLabelView.text = "Use Destroy Date:"
    }


    // ---------- Switch view ----------

    private func adjustSwitchViewLayout() {
        switchView.frame.origin = CGPoint(
            x: switchLabelView.frame.maxX + 8,
            y: noteTextView.frame.maxY + switchViewMarginTop
        )
    }

    private func setupSwitchView() {
        switchView.addTarget(self, action: #selector(switchViewChanged), for: UIControl.Event.valueChanged)
        switchViewChanged()
    }

    @objc private func switchViewChanged() {
        if (switchView.isOn) {
            dateView.isHidden = false
        } else {
            dateView.isHidden = true
        }
        updateUI()
    }


    // ---------- Date view ----------

    private func adjustDateViewLayout() {
        dateView.frame.origin = CGPoint(
            x: self.bounds.minX + sideMargin,
            y: switchView.frame.maxY + dateViewMarginTop
        )
        dateView.frame.size.width = self.bounds.maxX - self.bounds.minX - sideMargin * 2
        dateView.frame.size.height = 150
    }

    private func setupDateView() {}


    // ---------- Colors views ----------

    private func adjustColorsViewsLayout() {
        let colorsViewWidth = min(portraitWidth, self.bounds.size.width) - sideMargin * 2
        let colorViewSide = colorsViewWidth * 0.22
        let colorViewMargin = colorsViewWidth * 0.04

        colorsViewMarginLeft = self.bounds.size.width > portraitWidth
            ? (self.bounds.size.width - colorsViewWidth - sideMargin) / 2
            : 0

        colorsView.frame = CGRect(
            x: colorsViewMarginLeft + self.bounds.minX + sideMargin,
            y: dateView.isHidden
                ? (switchView.frame.maxY + colorsViewMarginTop)
                : (dateView.frame.maxY + colorsViewMarginTop),
            width: colorsViewWidth,
            height: colorViewSide
        )

        whiteColorSquare.frame = CGRect(
            x: colorsView.bounds.minX,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        redColorSquare.frame = CGRect(
            x: whiteColorSquare.frame.maxX + colorViewMargin,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        greenColorSquare.frame = CGRect(
            x: redColorSquare.frame.maxX + colorViewMargin,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        customColorSquare.frame = CGRect(
            x: greenColorSquare.frame.maxX + colorViewMargin,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        paletteSquare.frame = CGRect(
            x: customColorSquare.bounds.minX,
            y: customColorSquare.bounds.minY,
            width: customColorSquare.bounds.size.width,
            height: customColorSquare.bounds.size.height
        )

        markView.frame.origin.x = selectedColorSquare.frame.maxX - markView.frame.height - 5
        markView.drawMark()
    }

    private func setupColorsViews() {
        whiteColorSquare.layer.borderWidth = 1
        whiteColorSquare.layer.borderColor = UIColor.black.cgColor
        whiteColorSquare.backgroundColor = UIColor.white
        redColorSquare.layer.borderWidth = 1
        redColorSquare.layer.borderColor = UIColor.black.cgColor
        redColorSquare.backgroundColor = UIColor.red
        greenColorSquare.layer.borderWidth = 1
        greenColorSquare.layer.borderColor = UIColor.black.cgColor
        greenColorSquare.backgroundColor = UIColor.green
        customColorSquare.layer.borderWidth = 1
        customColorSquare.layer.borderColor = UIColor.black.cgColor

        paletteSquare.image = UIImage(named: "palette_icon")
        paletteSquare.isUserInteractionEnabled = false

        colorsView.addSubview(whiteColorSquare)
        colorsView.addSubview(redColorSquare)
        colorsView.addSubview(greenColorSquare)
        colorsView.addSubview(customColorSquare)
        colorsView.addSubview(markView)
        customColorSquare.addSubview(paletteSquare)
    }


    // ---------- Mark view ----------

    private func adjustMarkViewLayout() {
        markView.frame.origin.y = 5
    }

    private func setupMarkView() {
        markView.isHidden = true
        markView.isUserInteractionEnabled = false
        markView.setState(state: MarkView.states.colorFlag)
    }


    // ---------- View ----------

    private func setViewHeight() {
        var viewHeight: CGFloat =
            noteTitleViewMarginTop + noteTitleView.frame.size.height
                + noteTextViewMarginTop + noteTextView.frame.size.height
                + switchViewMarginTop + switchView.frame.size.height
                + colorsViewMarginTop + colorsView.frame.size.height

        if (!dateView.isHidden) {
            viewHeight += dateViewMarginTop + dateView.frame.size.height
        }

        self.frame.size.height = viewHeight
        self.parentScrollView()?.contentSize.height = viewHeight
    }
}


extension NoteEditView {
    func parentScrollView() -> UIScrollView? {
        return self.superview as? UIScrollView
    }
}


extension NoteEditView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if (textView == noteTextView) {
            adjustNoteTextViewSize()
        }
    }

    func adjustNoteTextViewSize() {
        let noteTextViewWidth = self.bounds.size.width - sideMargin * 2
        let noteTextViewFitsSize = noteTextView.sizeThatFits(CGSize(
            width: noteTextViewWidth,
            height: CGFloat.greatestFiniteMagnitude
        ))
        noteTextView.frame.size = CGSize(
            width: noteTextViewWidth,
            height: noteTextViewFitsSize.height
        )
    }
}
