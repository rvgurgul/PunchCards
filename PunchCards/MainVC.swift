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
     # = done
     
     # create punchcard creation menu/interface
     # create punchcard admin interface
        # list of codes
            # add alert
                # code text field
                    # generate a random code if empty?
            # remove
            + change values
            + change uses (both of these can be done with a single alert)
        # list of rewards
            - add alert
                - name text field
                - price text field
            # remove
            + change price
                + alert
        + set custom color(s)
        + set image url
     # create punchcard user interface
        # redeem button (redemption works, saving tickets does not)
        # list of redeemed tickets
        + rewards page
     
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
                    self.cards.append(PunchCard(name: name, dict: dict))
                    self.tableView.reloadData()
                }
            }
        })
        
        if userID == nil
        {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setUsername), userInfo: nil, repeats: false)
        }
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
        if selectedCard.adminID == userID //admin
        {
            goToView(withIdentifier: "AdminVC", handler:
            {   (view) in
                if let adminVC = view as? AdminMainVC
                {
                    adminVC.card = selectedCard
                }
            })
        }
        else //user
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
