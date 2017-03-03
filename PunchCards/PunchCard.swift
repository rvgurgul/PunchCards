//
//  PunchCard.swift
//  PunchCards
//
//  Created by Richie Gurgul on 2/21/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

//These will be created everytime the user loads the app.
class PunchCard
{
    var name: String!
    var image: UIImage?
    var adminID: String!
    var rewards: [String:Int]!
    var codes: [String:[String:Int]]!
    
    init(name: String, dict: [String:Any])
    {
        self.name = name
        
        if let temp = dict["admin"] as? String {
            self.adminID = temp
        }
        
        if let temp = dict["image"] as? String {
            if let url = URL(string: temp) {
                if let data = try? Data(contentsOf: url) {
                    self.image = UIImage(data: data)
                }
            }
        }
        
        if let temp = dict["codes"] as? [String:[String:Int]] {
            codes = temp
        }
        
        if let temp = dict["rewards"] as? [String:Int] {
            self.rewards = temp
        }
    }
    
    func redeem(code: String) -> Ticket?
    {
        if [String](codes.keys).contains(code)
        {
            var val = 1
            if let dict = codes[code]
            {
                val = dict["value"]!
            }
            return Ticket(name: name, code: code, val: val)
        }
        return nil
    }
}
