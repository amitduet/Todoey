//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Amit Chowdhury on 01/09/2020.
//  Copyright (c) 2020 Amit Chowdhury. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryItems = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCatories()
    }
    
    
    //MARK:- TableView Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryItems[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    //MARK:- TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desinationViewController = segue.destination as! ToDoListViewController
        if let  indexPath = tableView.indexPathForSelectedRow {
            desinationViewController.selectedCategory = categoryItems[indexPath.row]
        }
    }
    
    
    //MARK:- Data Manupulation Methods
    func loadCatories(with request:NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryItems = try context.fetch(request)
        }catch {
            debugPrint("Unable to read from Core data error is \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func categoriesSaveToCoreData(){
        
        do {
            try context.save()
        }catch {
            debugPrint("Unable to save to core data \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    //MARK:- BarButton Action
    @IBAction func addButtonPressed(_ sender:UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Cateory", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text, !text.isEmpty {
                
                let category = Category(context: self.context)
                category.name = text
                self.categoryItems.append(category)
                self.categoriesSaveToCoreData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}

