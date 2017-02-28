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
    var image: UIImage!
    var adminID: String!
//    var codes: [custom code class]
    var rewards: [String:Int]
                 //["Free Stuff": 5]
    
    init(name: String, data: String, rewards: [String:Int])
    {
        let url = URL(string: data)
        let data = try? Data(contentsOf: url!, options : [])
        self.name = name
        self.image = UIImage(data: data!)!
        self.rewards = rewards
    }
    
    /*
     init(Firebase reference?)
     
     get name
     get image
     get adminID
     
     
     
     */
}
