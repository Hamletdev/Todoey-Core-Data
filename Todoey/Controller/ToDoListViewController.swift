//
//  ViewController.swift
//  Todoey-NSCoder
//
//  Created by Amit Chaudhary on 11/29/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import CoreData

let reUseCellIdentifier = "ToDoListCell"

class ToDOListViewController: UITableViewController {
    
    let dataFilePath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let stagingContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var textField = UITextField()
    
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            self.loadItems()
        }
    }
    
    let itemSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRect.zero
        searchBar.placeholder = "Search Item"
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonPressed))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.title = self.selectedCategory?.name
        
        tableView.register(ToDoItemCell.self, forCellReuseIdentifier: reUseCellIdentifier)
        
        
        itemSearchBar.delegate = self
        self.tableView.tableHeaderView = itemSearchBar
        
    }
    
    @objc func addButtonPressed() {
        let alertController = UIAlertController(title: "Add an Item", message: "", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Add Item", style: UIAlertAction.Style.default) { (action) in
            
            let newItem = Item(context: self.stagingContext)
            newItem.title = self.textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItem()
            self.tableView.reloadData()
        }
        
        //add an uitextfield to alertcontroller
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = " Create new Item"
            self.textField = alertTextField
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


extension ToDOListViewController {
    //MARK: - TABLEVIEW DATA SOURCE
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseCellIdentifier, for: indexPath)
        
        let anItem = itemArray[indexPath.row]
        cell.textLabel?.text = anItem.title
        cell.accessoryType = anItem.done ? .checkmark : .none
        return cell
    }
    
    
    //MARK: - TABLEVIEW DELEGATE METHODS
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // delete data from persistentcontainer
//        stagingContext.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
       itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItem()
        tableView.reloadData()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - CREATE/SAVE AND READ DATA
    func saveItem() {
        
        do {
            try stagingContext.save()
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //load only from a selectedCategory
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", self.selectedCategory!.name!)
        request.predicate = categoryPredicate
        do {
            itemArray = try stagingContext.fetch(request)
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }
}

//MARK: - SEARCHBARDELEGATE
extension ToDOListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            self.loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
        if searchText.count != 0 {
            let searchRequest: NSFetchRequest<Item> = Item.fetchRequest()
            searchRequest.predicate = NSPredicate(format: "title CONTAINS %@", searchText)
            searchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            do {
                itemArray = try stagingContext.fetch(searchRequest)
            } catch  {
                print(error)
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

