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
    /*
     GITHUB:
     https://github.com/rvgurgul/PunchCards
     
     FIREBASE:
     https://punchcards-14936.firebaseio.com/
    
     =======================================================================================================
     
     MVP: As a user I want an app that will be a digital punch cards for businesses that store and tracks rewards.
        - User can create Cards that are stored onto a Google Firebase
        - Redeemed tickets are locally saved on the device
     
     Stretch 1: The app will have an admin and user feature.
        - Users can manage the cards they create
            - Can add/remove/edit codes with uses & values
            - Can add/remove/edit rewards with prices
        - Users can redeem codes in others' cards
            - Can view rewards by availability
     
     Stretch 2: Punches will be made secure via a password set by admin.
        - Codes can be manually entered on the Admin page or can be randomly generated
     
     Stretch 3: The punch cards will be 100% customizable based on the business needs.
        - Codes can have their uses & values adjusted based on the Admin's needs
     
     =======================================================================================================
     
     Known Issues:
        - Usernames do not show up on the initial load, after creating a card/navigating through the app, they should appear.
        - Codes are redeemable multiple times by 1 person, if I had more time to work on this app, this could be an easy fix.
     */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ref.child("all-groups").observeSingleEvent(of: .value, with:
        {   (snap) in
            if let groups = snap.value as? [String:[String:Any]]
            {
                let names = [String](groups.keys)
                for name in names
                {
                    let dict = groups[name]!
                    cards.append(PunchCard(name: name, dict: dict))
                    self.tableView.reloadData()
                }
            }
        })
        
        if userID == nil
        {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setUsername), userInfo: nil, repeats: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func actionButton(_ sender: AnyObject)
    {
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actions.addAction(UIAlertAction(title: "Create Punch Card", style: .default, handler: self.createCard))
        actions.addAction(UIAlertAction(title: "Change Username", style: .default, handler: self.setUsername))
        actions.addAction(cancelAction)
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
        
        cell.detailTextLabel?.text = "Owner:"
        if let name = usernames[card.adminID]{
            cell.detailTextLabel?.text = "Owner: \(name)"
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
        let selectedCard = cards[indexPath.row]
        
        //admin
        if selectedCard.adminID == userID
        {
            goToView(withIdentifier: "AdminVC", handler:
            {   (view) in
                if let adminVC = view as? AdminMainVC
                {
                    adminVC.card = selectedCard
                    adminVC.cardIndex = indexPath.row
                }
            })
        }
            
        //user
        else
        {
            goToView(withIdentifier: "UserVC", handler:
            {   (view) in
                if let userVC = view as? UserMainVC
                {
                    userVC.card = selectedCard
                }
            })
        }
        
        selectedCard.printSelf()
    }
    
    func createCard(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "Create a Punch Card", message: "Enter a name:", preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:
        {   _ in
            if let input = alert.textFields?[0].text
            {
                self.cardChecker(input)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func cardChecker(_ name: String)
    {
        ref.child("all-groups").observeSingleEvent(of: .value, with:
        {   (snap) in
            if let groups = snap.value as? [String:Any]
            {
                let names = [String](groups.keys)
                if names.contains(name)
                {
                    self.cardFailure(name)
                }
                else
                {
                    self.cardSuccess(name)
                }
            }
        })
    }
    
    func cardSuccess(_ name: String)
    {
        let newCard = PunchCard(name: name, dict: ["adminID":userID])
        cards.append(newCard)
        tableView.reloadData()
        
        if let id = userID
        {
            set(id, forKey: "all-groups/\(name)/adminID")
        }
        
        let alert = UIAlertController(title: "Card successfully added.", message: "You can now manage this card by selecting it.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Admin Page", style: .default, handler:
        {   _ in
            self.goToView(withIdentifier: "AdminVC", handler:
            {   (view) in
                if let adminVC = view as? AdminMainVC
                {
                    adminVC.card = newCard
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func cardFailure(_ name: String)
    {
        let alert = UIAlertController(title: "Could not create card.", message: "One already exists with the name \(name).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: self.createCard))
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setUsername(_: UIAlertAction)
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
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: self.setUsername))
        present(alert, animated: true, completion: nil)
    }
    
    func usernameSuccess(_ name: String)
    {
        userID = userID ?? UUID().uuidString
        set(name, forKey: "all-users/\(userID!)")
        
        let alert = UIAlertController(title: "Access Granted", message: "Your username is \(name).", preferredStyle: .alert)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
}
