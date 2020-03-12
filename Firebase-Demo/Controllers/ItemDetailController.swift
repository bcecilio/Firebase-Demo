//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemDetailController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var likeButton: UIBarButtonItem!
    
    private var item: Item
    private var originalValueForConstraint: CGFloat = 0
    private lazy var zeTabGestureOuiOui: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        return gesture
    }()
    private let database = DatabaseService()
    private var listener: ListenerRegistration?
    private var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        return formatter
    }()
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = item.itemName
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        originalValueForConstraint = containerBottomConstraint.constant
        commentTextField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        registerKeyboardNotification()
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "try again", message: "\(error)")
                }
            } else if let snapshot = snapshot {
                let comments = snapshot.documents.map {Comment($0.data())}
                self?.comments = comments.sorted {$0.commentDate.dateValue() < $1.commentDate.dateValue()}
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotification()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            showAlert(title: "Missing Fields", message: "error")
            return
        }
        postComment(text: commentText)
    }
    
    private func postComment(text: String) {
        database.postComment(item: item, comment: text) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try Again", message: "\(error.localizedDescription)")
                }
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: "Comment Posted!", message: nil)
                }
            }
        }
    }
    
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundUserInfoKey"] as? CGRect else {
            return
        }
        // adjust the container bottom constraint
        containerBottomConstraint.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        dismissKeyboard()
    }
    
    @objc private func dismissKeyboard() {
        containerBottomConstraint.constant = originalValueForConstraint
        commentTextField.resignFirstResponder()
    }
    
    @IBAction func likeButtonPressed(_ sender: UIBarButtonItem) {
        
    }
}

extension ItemDetailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

extension ItemDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let commentsCell = comments[indexPath.row]
        let date = dateFormatter.string(from: commentsCell.commentDate.dateValue())
        cell.textLabel?.text = commentsCell.text
        cell.detailTextLabel?.text = "@" + commentsCell.commentNBy + " " + date
        return cell
    }
}
