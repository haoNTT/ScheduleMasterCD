//
//  CategoryTableViewController.swift
//  ScheduleMaster
//
//  Created by Haonan Tian on 5/10/20.
//  Copyright © 2020 Haonan Tian. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: SwipeCellViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaultPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
    var cateArray: [Categories]?
    //var cateArray  = ["Category1", "Category2", "Category3"]
    var selected : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        //print(defaultPath)
        //let a = try context.fetch(NSFetchRequest(entityName: "Category"))
        //print(defaultPath)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cateArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let safeArray = self.cateArray {
            cell.textLabel?.text = safeArray[indexPath.row].cateName
            cell.selectionStyle = .gray
        } else {
            cell.textLabel?.text = "Add new category"
            cell.selectionStyle = .none
        }


        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected = indexPath.row
        if self.cateArray != nil {
            performSegue(withIdentifier: "CategoryToItems", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemTableViewController
        if let safeArray = self.cateArray {
            destinationVC.selectedCategory = safeArray[selected!]
        }
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var tempField = UITextField()
        
        let addAlert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let safeString = tempField.text {
                if safeString != "" {
                    let newCate = Categories(context: self.context)
                    newCate.cateName = safeString
                    if self.cateArray != nil {
                        self.cateArray!.append(newCate)
                    } else {
                        self.cateArray = [newCate]
                    }
                    self.saveItems()
                    self.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        addAlert.addTextField { (inputField) in
            inputField.placeholder = "type name of the category to create"
            tempField = inputField
        }
        
        addAlert.addAction(cancelAction)
        addAlert.addAction(action)
        present(addAlert, animated: true)
    }
    
    override func deletion(with indexPath: IndexPath) {
        self.context.delete(self.cateArray![indexPath.row])
        self.cateArray?.remove(at: indexPath.row)
        do {
            try context.save()
        } catch {
            print("fail to delete item due to \(error)")
        }
    }
    
    func loadData() {
        let request = NSFetchRequest<Categories>(entityName: "Categories")
        
        do {
            try self.cateArray = context.fetch(request)
        } catch {
            print("Fail to load file with error \(error)")
        }
        
        if self.cateArray != nil {
            self.tableView.reloadData()
        }
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Fail to save item due to \(error)")
        }
    }
    
}
