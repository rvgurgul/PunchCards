//
//  GlobalUtility.swift
//  PunchCards
//
//  Created by Richie Gurgul on 3/2/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

var ref: FIRDatabaseReference
{
    return FIRDatabase.database().reference()
}

var userID: String?
{
    return UserDefaults.standard.string(forKey: "id")
}

func set(_ val: Any, forKey key: String)
{
    ref.updateChildValues([key:val])
}

var punches = [String:[Ticket]]()

func load()
{
    if let data = UserDefaults.standard.object(forKey: "saved") as? [String:[Ticket]]
    {
        punches = data
    }
}

func save()
{
    UserDefaults.standard.set(punches, forKey: "saved")
}

var randomCode: String
{
    var code = ""
    var chars = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".characters)
    for _ in 0..<3 {
        code += "\(chars[Int(arc4random_uniform(UInt32(chars.count)))])"
    }
    code += "-"
    for _ in 0..<3 {
        code += "\(chars[Int(arc4random_uniform(UInt32(chars.count)))])"
    }
    code += "-"
    for _ in 0..<3 {
        code += "\(chars[Int(arc4random_uniform(UInt32(chars.count)))])"
    }
    return code
}

