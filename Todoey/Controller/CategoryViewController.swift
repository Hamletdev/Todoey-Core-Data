//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Amit Chaudhary on 12/2/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import CoreData

fileprivate let reUseCategoryCell = "CategoryCellIdentifier"

class CategoryViewController: UITableViewController {
    
    var categoriesArray = [Category]()
    let categoryContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonPressed))
        self.navigationItem.rightBarButtonItem = addButton
        self.tableView.register(CategoryViewCell.self, forCellReuseIdentifier: reUseCategoryCell)
        
        self.loadCategories()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseCategoryCell, for: indexPath)
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        cell.detailTextLabel?.text = String(describing: (categoriesArray[indexPath.row].items?.count)!)
        cell.detailTextLabel?.textColor = .systemGray4
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoListVC = ToDOListViewController()
        todoListVC.selectedCategory = categoriesArray[indexPath.row]
        self.navigationController?.pushViewController(todoListVC, animated: true)
    }

    
    @objc func addButtonPressed() {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Add a Category", message: "", preferredStyle: UIAlertController.Style.alert)
        let addAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { (action) in
            //create a new nsmanagedobject
            let newCategory = Category(context: self.categoryContext)
            newCategory.name = textField.text
            self.categoriesArray.append(newCategory)
            self.saveCategory()
        
        }
        alertController.addAction(addAction)
        alertController.addTextField { (field) in
            textField = field
            textField.placeholder = "Enter Category Name"
        }
        self.present(alertController, animated: true, completion: nil)
    }



}

//MARK: - SAVE/ READ DATA
extension CategoryViewController {
    func saveCategory() {
        do {
            try categoryContext.save()
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
           categoriesArray = try categoryContext.fetch(request)
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }
}
