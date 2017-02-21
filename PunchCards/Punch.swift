//
//  Punch.swift
//  PunchCards
//
//  Created by Richie Gurgul on 2/21/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class Punch: NSCoding
{
    var date: Date!
    var desc: String!
    
    init(desc: String)
    {
        self.date = Date()
        self.desc = desc
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        self.desc = aDecoder.decodeObject(forKey: "desc") as! String
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(desc, forKey: "desc")
    }
}
