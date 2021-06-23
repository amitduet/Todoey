//
//  TableViewController.swift
//  Todoey
//
//  Created by Amit Chowdhury on 01/09/2020.
//  Copyright (c) 2020 Amit Chowdhury. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [ToDoItem]()
    var selectedCategory:Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK:- Data Store and Load
    
    func loadItems(with request:NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate:NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let optionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [optionalPredicate, categoryPredicate])
        }
        request.predicate = categoryPredicate
        
        do {
            itemArray = try context.fetch(request)
        }catch {
            debugPrint("Unable to read from Core data error is \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func saveToCoreData(){
        
        do {
            try context.save()
        }catch {
            debugPrint("Unable to save to core data \(error)")
        }
        self.tableView.reloadData()
    }
    
    //MARK:- BarButton Action
    @IBAction func addButtonPressed(_ sender:UIBarItem){
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let text = textField.text {
                
                let newItem = ToDoItem(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveToCoreData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Tableview data source Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark:.none
        return cell
    }

    //MARK:- Tableview delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveToCoreData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- Searchbar Delegate
extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with:request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0){
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
