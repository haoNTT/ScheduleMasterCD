//
//  TimelineTableViewController.swift
//  ScheduleMaster
//
//  Created by Haonan Tian on 5/11/20.
//  Copyright © 2020 Haonan Tian. All rights reserved.
//

import UIKit
import CoreData
import TimelineTableViewCell

class TimelineTableViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var currentSelected: Items?
    var allItems: [Items]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
            bundle: Bundle(url: nibUrl!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allItems?.count ?? 1
    }
    
    func findSelectedIndex() -> Int? {
        var idx = 0
        while idx < self.allItems!.count {
            if self.currentSelected == self.allItems?[idx] {
                return idx
            }
            idx += 1
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedIdx = self.findSelectedIndex()
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell
        
        if let safeItems = self.allItems, let safeIndex = selectedIdx {
            cell.titleLabel?.text = safeItems[indexPath.row].title
            cell.bubbleRadius = 10.0
            
            if self.allItems?[indexPath.row].note != nil {
                cell.descriptionLabel.text = self.allItems?[indexPath.row].note
            }
            
            if indexPath.row == safeIndex {
                cell.timeline.frontColor = UIColor.black
                cell.timeline.backColor = UIColor(red: 1.00, green: 0.28, blue: 0.28, alpha: 1.00)
                cell.bubbleColor = UIColor(red: 1.00, green: 0.28, blue: 0.28, alpha: 1.00)
                cell.timelinePoint.color = UIColor(red: 1.00, green: 0.28, blue: 0.28, alpha: 1.00)
                cell.timelinePoint.diameter = 10.0
                cell.timelinePoint.isFilled = true
            } else if indexPath.row < safeIndex{
                cell.timeline.frontColor = UIColor.black
                cell.timeline.backColor = UIColor.black
                cell.bubbleColor = UIColor.black
                cell.timelinePoint.isFilled = true
            } else {
                cell.timeline.frontColor = UIColor.lightGray
                cell.timeline.backColor = UIColor.lightGray
                cell.bubbleColor = UIColor.lightGray
                cell.timelinePoint.isFilled = false
                if indexPath.row - 1 == safeIndex {
                    cell.timeline.frontColor = UIColor(red: 1.00, green: 0.28, blue: 0.28, alpha: 1.00)
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tempField = UITextField()
        let alert = UIAlertController(title: "Add a note?", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            // Update the information and save it to database
            if let safeText = tempField.text {
                if safeText != "" {
                    self.allItems?[indexPath.row].note = safeText
                    do {
                        try self.context.save()
                    } catch {
                        print("Fail to save the updates to database due to \(error)")
                    }
                    self.tableView.reloadData()
                }
            }
            
        }
        
        alert.addTextField { (inputField) in
            inputField.placeholder = "Type in the notes..."
            tempField = inputField
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }

}
