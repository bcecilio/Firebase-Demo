//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var titleForItem: UITextField!
    @IBOutlet weak var priceForItem: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    private var category: Category
    private let dbService = DatabaseService()
    private let storageService = StorageService()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
       let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOption))
        return gesture
    }()
    
    private var selectedItemImage: UIImage? {
        didSet {
            itemImageView.image = selectedItemImage
        }
    }
    
    init?(coder: NSCoder, category: Category) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showPhotoOption() {
        let alertController = UIAlertController(title: "Choose photo", message: nil, preferredStyle: .actionSheet)
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
    
    @IBAction func sellButtonPressed(_ sender: UIBarButtonItem) {
        guard let itemName = titleForItem.text, !itemName.isEmpty, let priceText = priceForItem.text, !priceText.isEmpty, let price = Double(priceText), let selectedImage = selectedItemImage else {
            showAlert(title: "Missing Fields", message: "All fields are required.")
            return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please create a username in your profile settings.")
            return
        }
        
        let resizeImage = UIImage.resizeImage(originalImage: selectedItemImage!, rect: itemImageView.bounds)
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Error creating item: \(error.localizedDescription)")
                }
            case .success(let documentId):
                self?.uploadPhoto(image: resizeImage, documentId: documentId)
            }
        }
    }
    
    private func uploadPhoto(image: UIImage, documentId: String) {
        storageService.uploadPhoto(itemId: documentId, image: image) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
                }
            case.success(let url):
                    self?.updateItemImageURL(url, documentId: documentId)
            }
        }
    }
    
    private func updateItemImageURL(_ url: URL, documentId: String) {
        // update an existing document on firebase
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL": url.absoluteString]) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error updating Item", message: "\(error.localizedDescription)")
                }
            } else {
                // everything went okay
                print("everything updated")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("could not attain image")
        }
        selectedItemImage = image
    }
}
