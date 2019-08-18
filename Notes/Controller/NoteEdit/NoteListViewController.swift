//
//  NoteListViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-20.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit
import CoreData

class NoteListViewController: UIViewController {

    private let backendQueue = OperationQueue()
    private let dbQueue = OperationQueue()
    private let commonQueue = OperationQueue()
    var dbNoteContainer: NSPersistentContainer

    private var fileNotebook: FileNotebook? = nil
    private var notesArr: [Note] = []

    private let notesTableView = UITableView()

    private let editButtonText = "Edit"
    private let cancelEditButtonText = "Cancel"

    var refreshControl: UIRefreshControl!

    init(dbNoteContainer: NSPersistentContainer) {
        self.dbNoteContainer = dbNoteContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
            loadNotes()
        }
    }

    private func setupViews() {
        title = "Notes"
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
        notesTableView.register(TableCell.self, forCellReuseIdentifier: "tableCell")
        notesTableView.dataSource = self
        notesTableView.delegate = self

        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        notesTableView.addSubview(refreshControl)

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

    private func showNoteEditViewController(note: Note? = nil) {
        let noteEditViewController = NoteEditViewController()

        if (note != nil) {
            noteEditViewController.note = note
        }
        noteEditViewController.noteAddDelegate = self

        self.navigationController?.pushViewController(noteEditViewController, animated: true)
    }

    private func refreshTable(dependencyOp: Operation) {
        let refreshTableOp = BlockOperation() { [unowned self] in
            print("OP: refresh table")
            self.notesTableView.reloadData()
        }

        refreshTableOp.addDependency(dependencyOp)
        OperationQueue.main.addOperation(refreshTableOp)
    }

    @objc func pullToRefresh(_ sender: Any) {
        loadNotes()
        refreshControl.endRefreshing()
    }
}


// Data handling
extension NoteListViewController: NoteAddDelegate {

    func addNote(note: Note) {
        let saveNoteOp = SaveNoteOperation(
            note: note,
            notebook: fileNotebook!,
            backendQueue: backendQueue,
            dbQueue: dbQueue,
            dbNoteContainer: dbNoteContainer
        )
        let handleDataOp = BlockOperation() { [unowned saveNoteOp, unowned self] in
            self.fileNotebook = saveNoteOp.notebook
            self.notesArr = self.convertNotesToArray(notes: self.fileNotebook!.notes)
        }

        handleDataOp.addDependency(saveNoteOp)

        commonQueue.addOperation(saveNoteOp)
        commonQueue.addOperation(handleDataOp)

        refreshTable(dependencyOp: handleDataOp)
    }

    private func removeNote(note: Note) {
        let removeNoteOp = RemoveNoteOperation(
            note: note,
            notebook: fileNotebook!,
            backendQueue: backendQueue,
            dbQueue: dbQueue,
            dbNoteContainer: dbNoteContainer
        )
        let handleDataOp = BlockOperation() { [unowned removeNoteOp, unowned self] in
            self.fileNotebook = removeNoteOp.notebook
            self.notesArr = self.convertNotesToArray(notes: self.fileNotebook!.notes)
        }

        handleDataOp.addDependency(removeNoteOp)

        commonQueue.addOperation(removeNoteOp)
        commonQueue.addOperation(handleDataOp)

        refreshTable(dependencyOp: handleDataOp)
    }

    private func loadNotes() {
        let loadNotesOp = LoadNotesOperation(
            backendQueue: backendQueue,
            dbQueue: dbQueue,
            dbNoteContainer: dbNoteContainer
        )
        let handleDataOp = BlockOperation() { [unowned loadNotesOp, unowned self] in
            self.fileNotebook = loadNotesOp.notebook!
            self.notesArr = self.convertNotesToArray(notes: self.fileNotebook!.notes)
        }

        handleDataOp.addDependency(loadNotesOp)

        commonQueue.addOperation(loadNotesOp)
        commonQueue.addOperation(handleDataOp)

        refreshTable(dependencyOp: handleDataOp)
    }

    private func convertNotesToArray(notes: [String: Note]) -> [Note] {
        var notesArr: [Note] = []

        for note in notes {
            notesArr.append(note.value)
        }

        notesArr.sort(by: { $0.title < $1.title })

        return notesArr
    }
}


// Table
extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = TableCell(style: .subtitle, reuseIdentifier: nil)
        let note = notesArr[indexPath.row]

        cell.textLabel?.text = note.title
        cell.textLabel?.numberOfLines = 1
        cell.detailTextLabel?.text = note.content
        cell.detailTextLabel?.numberOfLines = 5
        cell.setColor(note.color)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Notes"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showNoteEditViewController(note: notesArr[indexPath.row])
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
            removeNote(note: notesArr[indexPath.row])
        }
    }
}


class TableCell: UITableViewCell {

    private let colorView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {
        self.accessoryView = colorView
    }

    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 5
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.gray.cgColor
    }
}
