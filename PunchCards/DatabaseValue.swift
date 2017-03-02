//
//  DatabaseValue.swift
//  PunchCards
//
//  Created by Richie Gurgul on 3/1/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import Firebase

extension FIRDatabaseReference
{
    var value: Any?
    {
        get
        {
            var result: Any? = nil
            observe(.childAdded)
            {   (snapshot) in
                result = snapshot.value
            }
            return result
        }
    }
}
