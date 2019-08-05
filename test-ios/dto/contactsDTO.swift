//
//  contactsDTO.swift
//  test-ios
//
//  Created by h4x0rs on 26/07/19.
//  Copyright © 2019 h4x0rs. All rights reserved.
//

import Foundation

class RootBank: Codable {
    var contas:[Conta] = [Conta]()
    var contatos:[String] = [String]()
}

class Conta: Codable {
    var name:String = ""
    var valor:Double = 0.0
}

