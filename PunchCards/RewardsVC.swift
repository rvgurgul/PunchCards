//
//  RewardsVC.swift
//  PunchCards
//
//  Created by Richie Gurgul on 3/10/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class RewardsVC: UITableViewController
{
    var card: PunchCard!
    var ticketVal = 0
    
    var available = [String:Int]()
    var unavailable = [String:Int]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard card != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        ticketVal = ticketValue(forCard: card)
        
        for reward in card.rewards{
            if reward.value <= ticketVal{
                available[reward.key] = reward.value
            }
            else{
                unavailable[reward.key] = reward.value
            }
        }
        
        navigationItem.title = "Rewards"
        navigationItem.prompt = "Your tickets: \(ticketVal)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        //0 - Available
        //1 - Unavailable
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0{
            return "Available"
        }
        
        if section == 1{
            return "Unavailable"
        }
        
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //AVAILABLE
        if section == 0{
            return available.count
        }
        
        //UNAVAILABLE
        if section == 1{
            return unavailable.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reward", for: indexPath)
        
        var dict = [String:Int]()
        if indexPath.section == 0{
            dict = available
        }
        else if indexPath.section == 1{
            dict = unavailable
        }
        
        let name = [String](dict.keys)[indexPath.row]
        cell.textLabel?.text = name
        let cost = "\([Int](dict.values)[indexPath.row])"
        cell.detailTextLabel?.text = cost

        return cell
    }
}
