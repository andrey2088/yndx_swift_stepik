//
//  NoteEditViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController {

    var notePresenter: NotePresenter!

    private let colorPickerViewController = ColorPickerViewController()
    private let noteEditScrollView = NoteEditScrollView(frame: CGRect.zero)
    private let noteEditView = NoteEditView(frame: CGRect.zero)

    private var keyboardHeight: CGFloat = 0
    var noteIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustLayouts()
    }

    override func viewWillAppear(_ animated: Bool) {
        if (self.isMovingToParent) {
            self.tabBarController?.tabBar.isHidden = true
            loadNoteIfPossible()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParent) {
            self.tabBarController?.tabBar.isHidden = false
            addNoteIfPossible()
        }
    }

    private func setupViews() {
        notePresenter.setNoteEditVCDelegate(self)

        title = "Note"
        noteEditView.frame.origin = CGPoint(
            x: noteEditScrollView.bounds.minX,
            y: noteEditScrollView.bounds.minY
        )

        view.backgroundColor = UIColor.white
        view.addSubview(noteEditScrollView)
        noteEditScrollView.addSubview(noteEditView)
        detectKeyboardEvents()
        colorsSquaresTaps()
    }

    private func adjustLayouts() {
        noteEditScrollView.frame = view.safeAreaLayoutGuide.layoutFrame
        noteEditScrollView.frame.size.height -= keyboardHeight
        noteEditView.frame.size.width = noteEditScrollView.bounds.size.width
    }


    // ---------- Note ----------

    private func addNoteIfPossible() {
        if (noteEditView.noteTitleView.text != "" || noteEditView.noteTextView.text != "") {
            let selfDestructDate: Date? = (noteEditView.switchView.isOn == true)
                ? noteEditView.dateView.date
                : nil
            return notePresenter.addNote(
                uid: noteEditView.noteUidView.text!,
                title: noteEditView.noteTitleView.text!,
                content: noteEditView.noteTextView.text!,
                color: noteEditView.noteColor,
                selfDestructDate: selfDestructDate
            )
        }
    }

    private func loadNoteIfPossible() {
        if let noteIndex = noteIndex {
            noteEditView.noteUidView.text = notePresenter.getNoteUidByIndex(noteIndex)
            noteEditView.noteTitleView.text = notePresenter.getNoteTitleByIndex(noteIndex)
            noteEditView.noteTextView.text = notePresenter.getNoteContentByIndex(noteIndex)
            if let selfDestructDate = notePresenter.getNoteSelfDestructDateByIndex(noteIndex) {
                noteEditView.switchView.isOn = true
                noteEditView.dateView.date = selfDestructDate
                noteEditView.dateView.isHidden = false
            }

            noteEditView.noteColor = notePresenter.getNoteColorByIndex(noteIndex).extendedSRGB()
        }
    }


    // ---------- Colors squares taps ----------

    private func colorsSquaresTaps() {
        let whiteColorTap = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        let redColorTap = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        let greenColorTap = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        let customColorTap = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        noteEditView.whiteColorSquare.addGestureRecognizer(whiteColorTap)
        noteEditView.redColorSquare.addGestureRecognizer(redColorTap)
        noteEditView.greenColorSquare.addGestureRecognizer(greenColorTap)
        noteEditView.customColorSquare.addGestureRecognizer(customColorTap)

        let customColorLongTap = UILongPressGestureRecognizer(
            target: self,
            action: #selector (customSquareLongTapped(sender:))
        )
        customColorLongTap.minimumPressDuration = 0.5
        noteEditView.customColorSquare.addGestureRecognizer(customColorLongTap)
    }

    @objc private func colorSquareTapped(sender: UIGestureRecognizer) {
        if let colorSquare = sender.view as? ColorSquareView {
            if (colorSquare != noteEditView.customColorSquare) {
                noteEditView.noteColor = colorSquare.color
                noteEditView.updateUI()
            }

            if (colorSquare == noteEditView.customColorSquare) {
                if (noteEditView.customColorSet) {
                    noteEditView.noteColor = colorSquare.color
                    noteEditView.updateUI()
                } else {
                    showColorPickerViewController()
                }
            }
        }
    }

    @objc private func customSquareLongTapped(sender: UIGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began) {
            showColorPickerViewController()
        }
    }

    private func showColorPickerViewController() {
        view.endEditing(true)
        colorPickerViewController.setSelectedColor(noteEditView.noteColor)
        colorPickerViewController.colorPickDelegate = self
        self.navigationController?.pushViewController(colorPickerViewController, animated: false)
    }


    // ---------- Keyboard events ----------

    private func detectKeyboardEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object:nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide(notification:)),
            name: UIResponder.keyboardDidHideNotification,
            object:nil
        )

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        let detectedKeyboardHeight =
            (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        keyboardHeight = detectedKeyboardHeight
        adjustLayouts()
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        keyboardHeight = 0
        adjustLayouts()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        keyboardHeight = 0
        adjustLayouts()
    }
}


extension NoteEditViewController: NoteEditVCDelegate {

}


extension NoteEditViewController: ColorPickDelegate {

    func didColorPicked(color: UIColor) {
        noteEditView.noteColor = color
        noteEditView.updateUI()
    }
}
