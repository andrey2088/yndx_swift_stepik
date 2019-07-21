//
//  ListViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class NoteListViewController: UIViewController {

    private let editButtonText = "Edit"
    private let cancelEditButtonText = "Cancel"

    private let fileNotebook = FileNotebook()
    private var notes: [Note] = []

    let notesTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustLayouts()
    }

    override internal func viewWillAppear(_ animated: Bool) {
        if (self.isMovingToParent) {
            fillNotesFromFileNotebook()
        } else {
            fileNotebook.loadFromFile()
            print("fileNotebook loaded")
            refreshTable()
        }
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: editButtonText,
            style: .plain,
            target: self,
            action: #selector(editTapped(_:))
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(plusTapped(_:))
        )
        notesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        notesTableView.dataSource = self
        notesTableView.delegate = self
        view.addSubview(notesTableView)
    }

    private func adjustLayouts() {
        notesTableView.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    @objc private func editTapped(_ sender: Any) {
        if (notesTableView.isEditing == false) {
            notesTableView.isEditing = true
            navigationItem.leftBarButtonItem?.title = cancelEditButtonText
            navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.font: UIFont.boldSystemFont(ofSize: 16)],
                for: .normal
            )
        } else {
            notesTableView.isEditing = false
            navigationItem.leftBarButtonItem?.title = editButtonText
            navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.font: UIFont.systemFont(ofSize: 16)],
                for: .normal
            )
        }
    }

    @objc private func plusTapped(_ sender: Any) {
        showNoteEditViewController()
    }

    private func showNoteEditViewController(editingNoteUid: String? = nil) {
        let noteEditViewController = NoteEditViewController()

        if (editingNoteUid != nil) {
            noteEditViewController.editingNoteUid = editingNoteUid
        }

        self.navigationController?.pushViewController(noteEditViewController, animated: true)
    }

    private func fillNotesFromFileNotebook() {
        notes = fileNotebook.getNotesArraySortedByTitle()
        print("notes filled")
    }

    private func refreshTable() {
        fillNotesFromFileNotebook()
        notesTableView.reloadData()
        print("table refreshed")
    }
}


extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNotebook.notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let note = notes[indexPath.row]

        cell.textLabel?.text = note.title
        cell.textLabel?.numberOfLines = 1
        cell.detailTextLabel?.text = note.content
        cell.detailTextLabel?.numberOfLines = 5

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Notes"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showNoteEditViewController(editingNoteUid: notes[indexPath.row].uid)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if (editingStyle == .delete) {
            fileNotebook.remove(with: notes[indexPath.row].uid)
            fileNotebook.saveToFile()
            refreshTable()
        }
    }
}
