//
//  ViewController.swift
//  SSLPinning
//
//  Created by Igor Medelian on 9/27/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet private var tableView: UITableView!
  
  private var selectedUser: User?
  
  var users: [User] = [] {
    didSet {
      tableView.isHidden = false
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NetworkClient().fetshUsers(completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(users):
        self.users = users
      case let .failure(error):
        self.presentError(withTitle: "Oops!", message: error.localizedDescription)
        }
    })
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailSegue",
      let destination = segue.destination as? DetailViewController,
      let cell = sender as? UITableViewCell,
      let indexPath = tableView.indexPath(for: cell) {
      destination.user = users[indexPath.item]
      cell.isSelected = false
    }
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = users[indexPath.item].displayName
    return cell
  }
}
