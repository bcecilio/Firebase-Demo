//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

enum ViewState {
    case items
    case favorites
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private var selectedImage: UIImage? {
        didSet {
            profileImage.image = selectedImage
        }
    }
    
    private let storageService = StorageService()
    private let database = DatabaseService()
    private var viewState: ViewState = .items {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var myFavorites = [Favorties]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
        private var myItems = [Item]() {
            didSet {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        updateUI()
        loadData()
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    @objc private func loadData() {
        fetchItems()
        fetchFavorites()
    }
    
    @objc private func fetchItems() {
        guard let user = Auth.auth().currentUser else {
            refreshControl.endRefreshing()
            return
        }
        database.fetchUserItems(userId: user.uid) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fetching Error", message: error.localizedDescription)
                }
            case .success(let items):
                self?.myItems = items
            }
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func fetchFavorites() {
        database.fetchFavorites() { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fetching Error", message: error.localizedDescription)
                }
            case .success(let favorites):
                self?.myFavorites = favorites
            }
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        emailLabel.text = user.email
        displayNameTextField.text = user.displayName
        profileImage.kf.setImage(with: user.photoURL)
    }
    
    private func updateDatabaseUser(displayName: String, imageUrl: String) {
        database.updateDatabaseUser(displayName: displayName, imageUrl: imageUrl) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success:
                print("successfully updated user")
            }
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Profile Picture", message: nil, preferredStyle: .actionSheet)
        let camerAction = UIAlertAction(title: "Camera", style: .default) {
            alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: "Choose from Library", style: .default) {
            alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(camerAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
        guard let displayName = displayNameTextField.text, !displayName.isEmpty, let selectedImage = selectedImage else {
            print("missing fields")
            return
        }
        
        guard let user = Auth.auth().currentUser else {return}
        
        let resizeImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImage.bounds)
        
        print("original image size: \(selectedImage.size)")
        print("original image size: \(resizeImage)")
        
        storageService.uploadPhoto(userId: user.uid, image: resizeImage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Error uploading photo: \(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateDatabaseUser(displayName: displayName, imageUrl: url.absoluteString)
                
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                request?.photoURL = url
                request?.displayName = displayName
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Could not change display name", message: "Error changing display name: \(error.localizedDescription)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Success!", message: "Your display name has changed successfully.")
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        
        // toggle current viewState
        switch sender.selectedSegmentIndex {
        case 0:
            viewState = .items
        case 1:
            viewState = .favorites
        default:
            break
        }
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
            UIViewController.showViewController(storyboardName: "LoginView", viewControllerId: "LoginViewController")
        } catch {
            DispatchQueue.main.async {
                self.showAlert(title: "Error signing out", message: "\(error.localizedDescription)")
            }
        }
    }
    
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        selectedImage = image
        dismiss(animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewState == .items {
            return myItems.count
        } else {
            return myFavorites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not downcast ItemCell")
        }
        if viewState == .items {
            let item = myItems[indexPath.row]
            cell.configureCell(for: item)
        } else {
            let favorite = myFavorites[indexPath.row]
            cell.configureCell(for: favorite)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
