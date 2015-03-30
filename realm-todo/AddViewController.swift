//
//  AddViewController.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/30.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import UIKit
import Realm

class AddViewController: UIViewController, UITextFieldDelegate {
    
    var textField: UITextField?
    var newItemText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        setupTextField()
        setupNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textField?.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTextField() {
        textField = UITextField(frame: CGRectZero)
        textField?.placeholder = "Type in item"
        textField?.delegate = self
        view.addSubview(textField!);
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding = CGFloat(11)
        textField?.frame = CGRectMake(padding, self.topLayoutGuide.length + 50, view.frame.size.width - padding * 2, 100)
    }

    func doneAction() {
        let realm = RLMRealm.defaultRealm()
        if self.textField?.text.utf16Count > 0 {
            let newOne = ToDoItem()
            newOne.name = self.textField!.text
            realm.transactionWithBlock({ () -> Void in
                realm.addObject(newOne)
            })
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doneAction()
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
