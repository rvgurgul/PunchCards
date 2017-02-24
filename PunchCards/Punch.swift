//
//  Punch.swift
//  PunchCards
//
//  Created by Richie Gurgul on 2/22/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation

//These are the things that get saved locally onto the device.
class Punch: NSCoding
{
    var date: Date!
    var name: String!
    var code: String!
    var val: Int!
    
    init(name: String, code: String, val: Int!)
    {
        self.date = Date()
        self.name = name
        self.code = code
        self.val  = val
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.code = aDecoder.decodeObject(forKey: "code") as! String
        self.val  = aDecoder.decodeInteger(forKey: "val")
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(code, forKey: "code")
        aCoder.encode(val , forKey: "val" )
    }
}
