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
     
     
     TO DO:
     - = necessary 
     + = stretch
     
     - create punchcard creation menu/interface
     - create punchcard admin interface
        - list of codes
            - add (manually or randomly)
            - remove
            + change values
            + change uses
        + set custom color(s)
        + set image url
     - create punchcard user interface
        - redeem button
        - list of redeemed tickets
        + rewards page
     
     
     
     */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        load()
        
        ref.child("all-groups").observeSingleEvent(of: .value, with:
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
        
        
        userID = nil
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
        cell.detailTextLabel?.text = "Owner: \(card.adminID)"
        
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
            let index = tableView.indexPathForSelectedRow?.row
            vc.card = cards[index!]
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
                self.usernameChecker(input)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func usernameChecker(_ name: String)
    {
        ref.child("all-users").observeSingleEvent(of: .value, with:
        {   (snap) in
            if let users = snap.value as? [String:String]
            {
                let names = [String](users.values)
                if names.contains(name)
                {
                    self.usernameFailure(name)
                }
                else
                {
                    self.usernameSuccess(name)
                }
            }
        })
    }
    
    func usernameFailure(_ name: String)
    {
        let alert = UIAlertController(title: "Access Denied", message: "The username \"\(name)\" is taken.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:
        {   _ in
            self.setUsername()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func usernameSuccess(_ name: String)
    {
        userID = UUID().uuidString
        set(name, forKey: "all-users/\(userID!)")
        
        let alert = UIAlertController(title: "Access Granted", message: "Your username is \(name).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
