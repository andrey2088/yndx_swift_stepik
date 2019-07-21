//
//  EditViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController {

    private let fileNotebook = FileNotebook()

    private let colorPickerViewController = ColorPickerViewController()
    private let noteEditScrollView = NoteEditScrollView(frame: CGRect.zero)
    private let noteEditView = NoteEditView(frame: CGRect.zero)

    private var keyboardHeight: CGFloat = 0
    private var customColorSelected: Bool = false
    private var customColor: UIColor = UIColor.white {
        didSet {
            customColorSelected = true
            noteEditView.customColorSquare.backgroundColor = customColor
        }
    }
    internal var editingNoteUid: String? = nil

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
            self.tabBarController?.tabBar.isHidden = true
            fillViewWithFileNotebookDataIfPossible()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParent) {
            self.tabBarController?.tabBar.isHidden = false
            addNoteToFileNotebookIfPossible()
        }
    }

    private func setupViews() {
        noteEditView.frame.origin = CGPoint(
            x: noteEditScrollView.bounds.minX,
            y: noteEditScrollView.bounds.minY
        )

        view.backgroundColor = UIColor.white
        view.addSubview(noteEditScrollView)
        noteEditScrollView.addSubview(noteEditView)
        detectKeyboardEvents()
        colorsSquaresTaps()

        colorPickerViewController.onDoneButtonTapped = { [weak self] color in DispatchQueue.main.async {
            self?.customColor = color
        }}
    }

    private func adjustLayouts() {
        noteEditScrollView.frame = view.safeAreaLayoutGuide.layoutFrame
        noteEditScrollView.frame.size.height -= keyboardHeight
        noteEditView.frame.size.width = noteEditScrollView.bounds.size.width
    }


    // ---------- Note ----------

    private func buildNoteWithEnteredData() -> Note? {
        if (noteEditView.noteTitleView.text != "" || noteEditView.noteTextView.text != "") {
            return Note(
                uid: noteEditView.noteUidView.text!,
                title: noteEditView.noteTitleView.text!,
                content: noteEditView.noteTextView.text!
            )
        }
        print("note not builded")
        return nil
    }

    private func addNoteToFileNotebookIfPossible() {
        if let note = buildNoteWithEnteredData() {
            fileNotebook.add(note)
            fileNotebook.saveToFile()
            print("note added/edited")
        }
    }

    private func fillViewWithFileNotebookDataIfPossible() {
        if (editingNoteUid == nil) {
            return
        }

        let note = fileNotebook.notes[editingNoteUid!]
        if (note == nil) {
            return
        }

        noteEditView.noteUidView.text = note!.uid
        noteEditView.noteTitleView.text = note!.title
        noteEditView.noteTextView.text = note!.content
        if (note!.selfDestructDate != nil) {
            noteEditView.switchView.isOn = true
            noteEditView.dateView.date = note!.selfDestructDate!
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
            action: #selector (customSquarePressed(sender:))
        )
        customColorLongTap.minimumPressDuration = 0.5
        noteEditView.customColorSquare.addGestureRecognizer(customColorLongTap)
    }

    @objc private func colorSquareTapped(sender: UIGestureRecognizer) {
        let colorSquare: UIView? = sender.view

        if (colorSquare != nil) {
            noteEditView.selectedColorSquare = colorSquare!
            noteEditView.updateUI()
        }

        if (colorSquare == noteEditView.customColorSquare && !customColorSelected) {
            showColorPickerViewController()
        }
    }

    @objc private func customSquarePressed(sender: UIGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began) {
            noteEditView.selectedColorSquare = noteEditView.customColorSquare
            noteEditView.updateUI()
            showColorPickerViewController()
        }
    }

    private func showColorPickerViewController() {
        view.endEditing(true)
        noteEditView.paletteSquare.isHidden = true
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
