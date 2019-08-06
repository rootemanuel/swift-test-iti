//
//  test_iosTests.swift
//  test-iosTests
//
//  Created by h4x0rs on 26/07/19.
//  Copyright © 2019 h4x0rs. All rights reserved.
//

import XCTest
@testable import test_ios

class test_iosTests: XCTestCase {
    
    var contactsView: contactsTVC?
    var transferView: transferTVC?

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.contactsView = storyboard.instantiateViewController(withIdentifier: "contacts") as? contactsTVC
        self.transferView = storyboard.instantiateViewController(withIdentifier: "transfer") as? transferTVC
        
        self.contactsView?.loadView()
        self.contactsView?.viewDidLoad()
        
        self.transferView?.loadView()
        self.transferView?.viewDidLoad()
    }

    override func tearDown() {
    }
    
    func testHasATableViewContacts() {
        XCTAssertNotNil(self.contactsView?.tableView)
    }
    
    func testTableViewHasDelegateContacts() {
        XCTAssertNotNil(self.contactsView?.tableView.delegate)
    }
    
    func testTableViewHasDataSourceContacts() {
        XCTAssertNotNil(self.contactsView?.tableView.dataSource)
    }
    
    func testHasATableViewTransfer() {
        XCTAssertNotNil(self.transferView?.tableView)
    }
    
    func testTableViewHasDelegateTransfer() {
        XCTAssertNotNil(self.transferView?.tableView.delegate)
    }
    
    func testTableViewHasDataSourceTransfer() {
        XCTAssertNotNil(self.transferView?.tableView.dataSource)
    }
}
