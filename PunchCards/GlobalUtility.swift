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

var punchCards = [PunchCard]()
var userTickets = [String:[Ticket]]()
var usernames = [String:String]()

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
    
    ref.child("all-users").observe(.value, with:
    {   (snap) in
        if let dict = snap.value as? [String:String]
        {
            usernames = dict
        }
    })
}

func save()
{
    UserDefaults.standard.set(userTickets, forKey: "saved")
}

var randomCode: String
{
    return randomCode(withPattern: [3,3])
}

func randomCode(withPattern pattern: [Int]) -> String
{
    var code = ""
    let chars = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".characters)
    for i in 0..<pattern.count
    {
        for _ in 0..<pattern[i]
        {
            code += "\(chars[Int(arc4random_uniform(UInt32(chars.count)))])"
        }
        if i + 1 < pattern.count
        {
            code += "-"
        }
    }
    return code
}

var cancelAction: UIAlertAction{
    return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
}

var dismissAction: UIAlertAction{
    return UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
}

extension UIViewController
{
    func goToView(withIdentifier id: String, handler: (UIViewController) -> Void)
    {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: id)
        {
            handler(nextVC)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

