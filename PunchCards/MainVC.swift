//
//  MainVC.swift
//  PunchCards
//
//  Created by Richie Gurgul on 3/2/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class MainVC: UITableViewController
{
    var cards = [PunchCard]()
    
    /*
     GITHUB:
     https://github.com/rvgurgul/PunchCards
     
     FIREBASE:
     https://punchcards-14936.firebaseio.com/
     
     all-users
        UUID: "username"
     all-groups
        GROUP
            admin: "UUID"
            codes
                String: Int
            rewards
                String: Int
    
MVP: As a user I want an app that will be a digital punch cards for businesses that store and tracks rewards.
     - punchcards which the user has admin access to have are golden
     - tableview with each punchcard's image, title, and current punches displayed
     - tap on one to see detailed information/tableview with each punch's date and description
     
Stretch 1: The app will have an admin and user feature.
Stretch 2: Punches will be made secure via a password set by admin.
     
     - admin
        the tableview will display the active codes
        can manually enter a code
        can generate a random code
     
     - user
        the tableview will display the codes you have redeemed
        can redeem codes
        can view rewards
        can view redeemed tickets
     
Stretch 3: The punch cards will be 100% customizable based on the business needs.
        admin can set custom color
        admin can set image url
     
     */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        load()
        
        ref.child("all-groups").observe(.value, with:
        {   (snap) in
            if let groups = snap.value as? [String:[String:Any]]
            {
                let names = [String](groups.keys)
                for name in names
                {
                    let dict = groups[name]!
                    self.cards.append(PunchCard(name: name, dict: dict))
                }
            }
            self.tableView.reloadData()
        })
        
        if userID == nil
        {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setUsername), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func actionButton(_ sender: AnyObject)
    {
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actions.addAction(UIAlertAction(title: "Create Punch Card", style: .default, handler:
        {   _ in
            //present newPunchCardVC
        }))
        actions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actions, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return cards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath)
        let card = cards[indexPath.row]
        
        cell.textLabel?.text = card.name
        
        if let array = tickets[card.name]
        {
            let count = array.count
            cell.detailTextLabel?.text = "\(count)"
        }
        
        if let image = card.image {
            cell.imageView?.image = image
        }
        
        if card.adminID == userID {
            cell.backgroundColor = UIColor(colorLiteralRed: 218/255, green: 165/255, blue: 32/255, alpha: 1)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let card = cards[indexPath.row]
        
        if card.adminID == userID //admin
        {
            
        }
        else //user
        {
            performSegue(withIdentifier: "toUserView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? UserMainVC
        {
            //vc.card =
        }
    }
    
    func setUsername()
    {
        let alert = UIAlertController(title: "Choose a username.", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler:
        {   _ in
            if let input = alert.textFields?[0].text
            {
                if self.usernameExists(input)
                {
                    self.setUsername()
                }
                else
                {
                    UserDefaults.standard.set(UUID().uuidString, forKey: "id")
                    set(input, forKey: "all-users/\(userID)")
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func usernameExists(_ name: String) -> Bool
    {
        ref.child("all-users").observe(.value, with: getValue as! (FIRDataSnapshot) -> Void)
        
        
        var names: [String]?
        ref.child("all-users").observe(.value, with:
        {   (snap) in
            if let users = snap.value as? [String:String]
            {
                names = [String](users.values)
            }
        })
        if names != nil
        {
            return names!.contains(name)
        }
        return true
    }
    
    func getValue(snapshot: FIRDataSnapshot) -> Any
    {
        return snapshot.value
    }
}
