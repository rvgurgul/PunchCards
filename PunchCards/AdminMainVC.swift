//
//  AdminMainVC.swift
//  PunchCards
//
//  Created by Richie Gurgul on 3/3/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class AdminMainVC: UITableViewController
{
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var card: PunchCard!
    var cardIndex: Int!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard card != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        guard cardIndex != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        navigationBar.title = card.name
        
        navigationBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButton))
    }
    
    func actionButton()
    {
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actions.addAction(UIAlertAction(title: "New Code", style: .default, handler: addCode))
        actions.addAction(UIAlertAction(title: "New Reward", style: .default, handler: addReward))
        actions.addAction(UIAlertAction(title: "Delete Card", style: .destructive, handler: deleteConfirmation))
        actions.addAction(cancelAction)
        present(actions, animated: true, completion: nil)
    }
    
    func addCode(_: UIAlertAction)
    {
        let random = randomCode
        let alert = UIAlertController(title: "New Code", message: "Enter a code, otherwise one will randomly be generated.", preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = random
        }
        alert.addTextField
        {   (field) in
            field.placeholder = "Uses (def. 1)"
        }
        alert.addTextField
        {   (field) in
            field.placeholder = "Value (def. 1)"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler:
        {   _ in
            var code = random
            if let text = alert.textFields?[0].text{
                if text != ""{
                code = text
                }
            }
            
            var uses = Int((alert.textFields?[1].text)!) ?? 1
            var value = Int((alert.textFields?[2].text)!) ?? 1
            
            if uses <= 0 {uses = 1}
            if value <= 0 {value = 1}
            
            let dict = ["uses": uses, "value": value]
            set(dict, forKey: "all-groups/\(self.card.name)/codes/\(code)")
            self.card.codes[code] = dict
            self.tableView.reloadData()
        }))
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func addReward(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "New Reward", message: nil, preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = "Name"
        }
        alert.addTextField
        {   (field) in
            field.placeholder = "Cost"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler:
        {   _ in
            if let name = alert.textFields?[0].text, let costText = alert.textFields?[1].text{
                if name == ""{
                    let anotherAlert = UIAlertController(title: "Invalid Name", message: nil, preferredStyle: .alert)
                    anotherAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: self.addReward))
                    self.present(anotherAlert, animated: true, completion: nil)
                }
                else if let cost = Int(costText), cost > 0{
                    set(cost, forKey: "all-groups/\(self.card.name)/rewards/\(name)")
                    self.card.rewards[name] = cost
                    self.tableView.reloadData()
                }
                else{
                    let anotherAlert = UIAlertController(title: "Invalid Cost", message: "Should be an integer greater than 0.", preferredStyle: .alert)
                    anotherAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: self.addReward))
                    self.present(anotherAlert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteConfirmation(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "Are you sure you want to delete this Punch Card?", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: kerchoo))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func kerchoo(_: UIAlertAction)
    {
        cards.remove(at: cardIndex)
        ref.child("all-groups/\(self.card.name)").removeValue()
        let _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        //CODES
        if section == 0{
            return "Active Codes"
        }
            
        //REWARDS
        else if section == 1{
            return "Rewards"
        }
        
        return ""
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        //0 = CODES
        //1 = REWARDS
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //CODES
        if section == 0{
            return card.codes.count
        }
            
        //REWARDS
        else if section == 1{
            return card.rewards.count
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "code", for: indexPath)
        
        //CODES
        if indexPath.section == 0{
            let code = [String](card.codes.keys)[indexPath.row]
            cell.textLabel?.text = code
            
            if let values = card.codes[code]{
                let usesText = "Uses: \(values["uses"]!)"
                let valueText = "Value: \(values["value"]!)"
                cell.detailTextLabel?.text = "\(usesText)\n\(valueText)"
            }
        }
        
        //REWARDS
        else if indexPath.section == 1{
            let reward = [String](card.rewards.keys)[indexPath.row]
            cell.textLabel?.text = reward
            
            let price = [Int](card.rewards.values)[indexPath.row]
            cell.detailTextLabel?.text = "\(price) tickets"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //CODES
        if indexPath.section == 0{
            let code = [String](card.codes.keys)[indexPath.row]
            let uses = card.codes[code]?["uses"]
            let val = card.codes[code]?["value"]
            
            let alert = UIAlertController(title: "Edit Code", message: "\"\(code)\"", preferredStyle: .alert)
            alert.addTextField(configurationHandler:
            {   (field) in
                field.placeholder = "Uses"
                field.text = "\(uses!)"
            })
            alert.addTextField(configurationHandler:
            {   (field) in
                field.placeholder = "Value"
                field.text = "\(val!)"
            })
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:
            {   _ in
                if let text = alert.textFields?[0].text{
                    if let newUses = Int(text){
                        self.card.codes[code]?["uses"] = newUses
                        set(newUses, forKey: "all-groups/\(self.card.name)/codes/\(code)/uses")
                    }
                }
                
                if let text = alert.textFields?[1].text{
                    if let newVal = Int(text){
                        self.card.codes[code]?["value"] = newVal
                        set(newVal, forKey: "all-groups/\(self.card.name)/codes/\(code)/value")
                    }
                }
                
                tableView.reloadData()
            }))
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
            
        //REWARDS
        else if indexPath.section == 1{
            let reward = [String](card.rewards.keys)[indexPath.row]
            let price = card.rewards[reward]
            
            let alert = UIAlertController(title: "Edit Code", message: "\"\(reward)\"", preferredStyle: .alert)
            alert.addTextField(configurationHandler:
            {   (field) in
                field.placeholder = "Price"
                field.text = "\(price!)"
            })
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:
            {   _ in
                if let text = alert.textFields?[0].text{
                    if let newPrice = Int(text){
                        self.card.rewards[reward] = newPrice
                        set(newPrice, forKey: "all-groups/\(self.card.name)/rewards/\(reward)")
                    }
                }
                
                tableView.reloadData()
            }))
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete{
            if indexPath.section == 0{
                let code = [String](card.codes.keys)[indexPath.row]
                ref.child("all-groups/\(card.name)/codes/\(code)").removeValue()
                card.codes.removeValue(forKey: code)
            }
            else if indexPath.section == 1{
                let reward = [String](card.rewards.keys)[indexPath.row]
                ref.child("all-groups/\(card.name)/rewards/\(reward)").removeValue()
                card.rewards.removeValue(forKey: reward)
            }
            tableView.reloadData()
        }
    }
}
