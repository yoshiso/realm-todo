//
//  TableViewController.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/30.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import UIKit
import Realm

class TableViewController: UITableViewController {
    
    var token: RLMNotificationToken?
    
    var todos: RLMResults {
        get {
            let predicate = NSPredicate(format: "finished == false", argumentArray: nil)
            return ToDoItem.objectsWithPredicate(predicate)
        }
    }
    
    var finished: RLMResults {
        get {
            let predicate = NSPredicate(format: "finished == true", argumentArray: nil)
            return ToDoItem.objectsWithPredicate(predicate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        setupNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.token = RLMRealm.defaultRealm().addNotificationBlock({ (note, realm) -> Void in
            self.tableView.reloadData()
            println("TABLE RELOADED")
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        RLMRealm.defaultRealm().removeNotification(self.token)
        println("TableViewController willDisappear")
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonAction")
    }
    
    func addButtonAction() {
        let addvc = AddViewController()
        let nc = UINavigationController(rootViewController: addvc)
        presentViewController(nc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Int(todos.count)
        case 1:
            return Int(finished.count)
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "TODO"
        case 1:
            return "FINISHED"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var todoItem: ToDoItem?
        switch indexPath.section {
        case 0:
            todoItem = todos.objectAtIndex(UInt(indexPath.row)) as? ToDoItem
        case 1:
            todoItem = finished.objectAtIndex(UInt(indexPath.row)) as? ToDoItem
        default:
            fatalError("fuckin err")
        }
        
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        todoItem?.finished = !todoItem!.finished
        realm.commitWriteTransaction()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case 0:
            let todo = todos.objectAtIndex(UInt(indexPath.row)) as ToDoItem
            var attrTxt = NSMutableAttributedString(string: todo.name)
            attrTxt.addAttribute(NSStrikethroughStyleAttributeName, value: 0, range: NSMakeRange(0, attrTxt.length))
            cell.textLabel?.attributedText = attrTxt
        case 1:
            let todo = finished.objectAtIndex(UInt(indexPath.row)) as ToDoItem
            var attrTxt = NSMutableAttributedString(string: todo.name)
            attrTxt.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attrTxt.length))
            cell.textLabel?.attributedText = attrTxt
        default:
          fatalError("Fuck")
        }
        
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
