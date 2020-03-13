//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ItemFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    private var database = DatabaseService()
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again later", message: "firestore error: \(error)")
                }
            } else if let snapshot = snapshot { // this is the data in our firebase database
                let items = snapshot.documents.map { Item($0.data()) }
                self?.items = items.sorted{$0.listedDate.seconds > $1.listedDate.seconds}
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove() // no longer are we lsitening for changed in firebase
    }
}

extension ItemFeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not downcast to ItemCell")
        }
        let itemCell = items[indexPath.row]
        cell.configureCell(for: itemCell)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // perform deletion on item
            database.deleteItem(item: items[indexPath.row]) { [weak self] (result) in
                switch result {
                case.failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error Deleting Item", message: "\(error.localizedDescription)")
                    }
                case .success:
                    print("deleted succesfully")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.row]
        guard let user = Auth.auth().currentUser else {return false}
        
        if item.sellerId != user.uid {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "ItemDetailController") { (coder) in
            return ItemDetailController(coder: coder, item: item)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ItemFeedViewController: ItemCellDelegate {
    func didSelectSellerName(_ itemCell: ItemCell, item: Item) {
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        let sellerItemController = storyboard.instantiateViewController(identifier: "SellerItemsController") { (coder) in
            return SellerItemsController(coder: coder, item: item)
        }
        navigationController?.pushViewController(sellerItemController, animated: true)
    }
}
