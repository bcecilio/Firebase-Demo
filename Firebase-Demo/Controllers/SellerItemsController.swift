//
//  SellerItemsController.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SellerItemsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    private var item: Item
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "@" + item.sellerName
        configureTableView()
        fetchItems()
        fetchUserPhoto()
    }
    
    private func fetchItems() {
        // TODO: refactor databaseService and storage service to a singleton since we are creating a new instances throughout our application
        // DatabaseService {
        // private init() {}
        // static let shared = DatabaseService()
        // }
        DatabaseService().fetchUserItems(userId: item.sellerName) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Failed fetching", message: error.localizedDescription)
                }
            case .success(let items):
                self?.items = items
            }
        }
    }
    
    private func fetchUserPhoto() {
        Firestore.firestore().collection(DatabaseService.usersCollection).document(item.sellerId).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error fetching", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                if let imageURL = snapshot.data()?["imageURL"] as? String {
                    DispatchQueue.main.async {
                        self?.tableView.tableHeaderView = HeaderView(imageURL: imageURL)
                    }
                }
            }
        }
    }
    
    private func configureTableView() {
        // add a headerView to a tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
    }
}

extension SellerItemsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not downcast ItemCell")
        }
        let item = items[indexPath.row]
        cell.configureCell(for: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
