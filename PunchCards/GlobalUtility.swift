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
    set (value)
    {
        UserDefaults.standard.set(value, forKey: "id")
    }
    get
    {
        return UserDefaults.standard.string(forKey: "id")
    }
}

func set(_ val: Any, forKey key: String)
{
    ref.updateChildValues([key:val])
}

func getValue(forKey key: String) -> Any?
{
    var result: Any?
    ref.observeSingleEvent(of: .value, with:
    {   (snap) in
        result = snap.value
    })
    return result
}

var userTickets = [String:[Ticket]]()

func load()
{
    if let data = UserDefaults.standard.object(forKey: "saved") as? [String:[Ticket]]
    {
        userTickets = data
    }
    let tick1 = Ticket(name: "test", code: "ABCDEFG", val: 50)
    let tick2 = Ticket(name: "test", code: "QRST", val: 1)
    let tix1 = [tick1, tick2]
    userTickets["test"] = tix1
}

func save()
{
    UserDefaults.standard.set(userTickets, forKey: "saved")
}

func randomCode() -> String
{
    return randomCode(withPattern: [3,3])
}

func randomCode(withPattern partitions: [Int]) -> String
{
    var code = ""
    let chars = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".characters)
    for partition in partitions
    {
        for _ in 0..<partition
        {
            code += "\(chars[Int(arc4random_uniform(UInt32(chars.count)))])"
        }
        code += "-"
        
    }
    return code
}
