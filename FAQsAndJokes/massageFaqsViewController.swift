//
//  massageFaqsViewController.swift
//  FAQsAndJokes
//
//  Created by user217360 on 11/1/22.
//

import UIKit
import FirebaseDatabase

class massageFaqsViewController: UIViewController {
    
    private var dataSource: [(String, String)] = []
    private let database = Database.database().reference()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView?.dataSource = self
        tableView?.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddBtn))
        
        fetchItemsFromDataBase()

    }
    
    @objc func didTapAddBtn(){
        let alert = UIAlertController(title: "New FAQ", message: " ", preferredStyle: .alert)
        alert.addTextField{field in field.placeholder = "Enter New Item"}
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                                      if let textField = alert.textFields?.first,
                                         let text = textField.text,
                                         !text.isEmpty{
                                          self?.saveToDo(item: text)
                }
            }
        ))
    }
    
    func removeItemFromDatabase(itemKey: String){
        database.child("faqs/\(itemKey)").removeValue()
    }
    
    func saveToDo(item: String){
        //let key = "item_\(dataSource.count + 1)"
        database.child("faqs").childByAutoId().setValue(item)
        //fetchItemsFromDataBase()
    }
    
    func fetchItemsFromDataBase(){
        database.child("faqs").observe(.value){ [weak self] snapShot in
            guard let items = snapShot.value as? [String: String] else {
                return
            }
            
            self?.dataSource.removeAll()
            
            let sortedItems = items.sorted { $0.0 < $1.0 }
            for (key, item) in sortedItems {
                self?.dataSource.append((key, item))
            }
            self?.tableView.reloadData()
        }
        
    }

}
extension massageFaqsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
}

extension massageFaqsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //animation of swipe delete
        if editingStyle == .delete {
            //todo remove item from database nad data source
            removeItemFromDatabase(itemKey: dataSource[indexPath.row].0)
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
           
            
        }
    }
}

