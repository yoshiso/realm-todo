//
//  realm_todoTests.swift
//  realm-todoTests
//
//  Created by ShoYoshida on 2015/03/30.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import Quick
import Nimble

class ToDoItemSpec : QuickSpec {
    override func spec() {
        var todoItem: ToDoItem?
        
        beforeEach { () -> () in
            todoItem = ToDoItem()
        }
        
        describe("attributes", { () -> Void in
            
            it("has attr name") {
                expect(todoItem!.name).to(equal(""))
            }
        })


        
    }
}
