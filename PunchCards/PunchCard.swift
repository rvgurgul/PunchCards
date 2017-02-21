//
//  PunchCard.swift
//  PunchCards
//
//  Created by Richie Gurgul on 2/21/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class PunchCard: NSCoding
{
    var name: String
    var image: UIImage
    var punches: [Punch]
    
    init(name: String, data: Data, total: Int)
    {
        self.name = name
        self.image = UIImage(data: data)!
        self.punches = [Punch]()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.image = aDecoder.decodeObject(forKey: "image") as! UIImage
        self.punches = aDecoder.decodeObject(forKey: "punches") as! [Punch]
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.image, forKey: "image")
        aCoder.encode(self.punches, forKey: "punches")
    }

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
    
}
