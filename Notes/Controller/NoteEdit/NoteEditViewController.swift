//
//  NoteEditViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

protocol NoteAddDelegate {
    func addNote(note: Note)
}

class NoteEditViewController: UIViewController {

    private let colorPickerViewController = ColorPickerViewController()
    private let noteEditScrollView = NoteEditScrollView(frame: CGRect.zero)
    private let noteEditView = NoteEditView(frame: CGRect.zero)

    private var keyboardHeight: CGFloat = 0
    var note: Note? = nil
    var noteAddDelegate: NoteAddDelegate? = nil

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

    private func buildNoteWithEnteredData() -> Note? {
        if (noteEditView.noteTitleView.text != "" || noteEditView.noteTextView.text != "") {
            let selfDestructDate: Date? = (noteEditView.switchView.isOn == true)
                ? noteEditView.dateView.date
                : nil
            return Note(
                uid: noteEditView.noteUidView.text!,
                title: noteEditView.noteTitleView.text!,
                content: noteEditView.noteTextView.text!,
                color: noteEditView.noteColor,
                selfDestructDate: selfDestructDate
            )
        }

        return nil
    }

    private func addNoteIfPossible() {
        if
            let note = buildNoteWithEnteredData(),
            let noteAddDelegate = noteAddDelegate
        {
            noteAddDelegate.addNote(note: note)
        }
    }

    private func loadNoteIfPossible() {
        if let note = note {
            noteEditView.noteUidView.text = note.uid
            noteEditView.noteTitleView.text = note.title
            noteEditView.noteTextView.text = note.content
            if let selfDestructDate = note.selfDestructDate {
                noteEditView.switchView.isOn = true
                noteEditView.dateView.date = selfDestructDate
                noteEditView.dateView.isHidden = false
            }

            noteEditView.noteColor = note.color.extendedSRGB()
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


extension NoteEditViewController: ColorPickDelegate {

    func didColorPicked(color: UIColor) {
        noteEditView.noteColor = color
        noteEditView.updateUI()
    }
}
