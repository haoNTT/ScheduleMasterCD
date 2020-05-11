//
//  ItemTableViewController.swift
//  ScheduleMaster
//
//  Created by Haonan Tian on 5/10/20.
//  Copyright © 2020 Haonan Tian. All rights reserved.
//

import UIKit
import CoreData
import SnapKit
import TimelineTableViewCell

class ItemTableViewController: SwipeCellViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let reminderOptions = ["Yes", "No"]
    var reminderField = UITextField()
    var startField = UITextField()
    var endField = UITextField()
    
    var selectedCategory: Categories? {
        didSet {
            self.loadItem()
        }
    }
    var itemArray : [Items]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.itemArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let safeArray = self.itemArray {
            cell.textLabel?.text = safeArray[indexPath.row].title
            cell.selectionStyle = .default
        } else {
            cell.textLabel?.text = "Add new items"
            cell.selectionStyle = .none
        }

        // Configure the cell...

        return cell
    }
    
    override func deletion(with indexPath: IndexPath) {
        self.context.delete(self.itemArray![indexPath.row])
        if self.itemArray != nil {
            self.itemArray!.remove(at: indexPath.row)
        }
        do {
            try context.save()
        } catch {
            print("fail to delete item due to \(error)")
        }
    }
    //MARK:- Table view selection section
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.itemArray != nil {
            performSegue(withIdentifier: "ItemToTimeline", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TimelineTableViewController
        // Set current selected items
        destinationVC.currentSelected = self.itemArray![tableView.indexPathForSelectedRow?.row ?? 0]
        
        // Set all items in the timeline controller
        if let safeItems = self.loadAllItems() {
            destinationVC.allItems = safeItems
        }
    }
    
    func loadAllItems() -> [Items]? {
        let request : NSFetchRequest<Items> = NSFetchRequest(entityName: "Items")
        var allItemsRes: [Items]?
        
        do {
            allItemsRes = try context.fetch(request)
        } catch {
            print("Fail to load all items due to \(error)")
        }
        
        return allItemsRes
    }
    
    //MARK:- Picker data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    //MARK:- Picker selection section
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.reminderOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.reminderField.text = self.reminderOptions[row]
    }
    
    //MARK:- Add button section
    
    @objc func startDatePickerChanged(picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc func endDatePickerChanged(picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        endField.text = dateFormatter.string(from: picker.date)
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var titleField = UITextField()
        
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.addTarget(self, action: #selector(startDatePickerChanged(picker:)), for: .valueChanged)
        
        let endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.addTarget(self, action: #selector(endDatePickerChanged(picker:)), for: .valueChanged)
        
        let reminderPicker = UIPickerView()
        reminderPicker.delegate = self
        
        let addAlert = UIAlertController(title: "Add New Items", message: "", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Add", style: .default) { (action) in
            if let safeString = titleField.text {
                if safeString != "" {
                    let newItem = Items(context: self.context)
                    newItem.title = safeString
                    newItem.parentCategory = self.selectedCategory
                    
                    // Add start date & end date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    if dateFormatter.string(from: startDatePicker.date) != "" {
                        newItem.start = dateFormatter.string(from: startDatePicker.date)
                    }
                    
                    if dateFormatter.string(from: endDatePicker.date) != "" {
                        newItem.end = dateFormatter.string(from: endDatePicker.date)
                    }
                    
                    if self.reminderField.text != nil {
                        if self.reminderField.text == "true" {
                            newItem.reminder = true
                        } else {
                            newItem.reminder = false
                        }
                    }
                    
                    if self.itemArray != nil {
                        self.itemArray!.append(newItem)
                    } else {
                        self.itemArray = [newItem]
                    }
                    
                    self.saveItem()
                    self.tableView.reloadData()
                    //self.loadItem()
                }
            }
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        addAlert.addTextField { (inputField) in
            inputField.placeholder = "type name of the items to create"
            titleField = inputField
        }
        
        addAlert.addTextField { (inputField) in
            inputField.placeholder = "Select the start time"
            inputField.inputView = startDatePicker
            self.startField = inputField
        }
        
        
        addAlert.addTextField { (inputField) in
            inputField.placeholder = "Select the end time"
            inputField.inputView = endDatePicker
            self.endField = inputField
        }
        
        addAlert.addTextField { (inputField) in
            inputField.placeholder = "If set as reminder?"
            inputField.inputView = reminderPicker
            self.reminderField = inputField
        }
        
        addAlert.addAction(action1)
        addAlert.addAction(action2)
        present(addAlert, animated: true)
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("fail to save item due to \(error)")
        }
    }
    
    func loadItem() {
        let request : NSFetchRequest<Items>=NSFetchRequest(entityName: "Items")
        request.predicate = NSPredicate(format: "parentCategory.cateName MATCHES[cd] %@", self.selectedCategory!.cateName!)
        
        do {
            self.itemArray = try context.fetch(request)
        } catch {
            print("fail to load items due to \(error)")
        }
        
        if self.itemArray != nil {
            self.tableView.reloadData()
        }
    }
}
