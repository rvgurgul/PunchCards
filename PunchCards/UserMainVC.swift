//
//  UserMainVC.swift
//  PunchCards
//
//  Created by Richie Gurgul on 3/3/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class UserMainVC: UITableViewController
{
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var card: PunchCard!
    var tix: [Ticket]!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard card != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        tix = userTickets[card.name] ?? [Ticket]()
        
        navigationBar.title = card.name
    }
    
    @IBAction func actionsButton(_ sender: AnyObject)
    {
        let actions = UIAlertController(title: "Your tickets: \(ticketValue(forCard: card))", message: nil, preferredStyle: .actionSheet)
        actions.addAction(UIAlertAction(title: "See rewards", style: .default, handler:
        {   _ in
            self.goToView(withIdentifier: "RewardVC", handler:
            {   (view) in
                if let rewardVC = view as? RewardsVC
                {
                    rewardVC.card = self.card
                }
            })
        }))
        actions.addAction(UIAlertAction(title: "Redeem a code", style: .default, handler: redemption))
        actions.addAction(cancelAction)
        present(actions, animated: true, completion: nil)
    }
    
    func redemption(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "Enter a code:", message: "(case sensitive)", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Redeem", style: .default, handler:
        {   _ in
            if let code = alert.textFields?[0].text
            {
                if let ticket = self.card.redeem(code: code)
                {
                    if userTickets[self.card.name] == nil
                    {
                        userTickets[self.card.name] = [Ticket]()
                    }
                    
                    userTickets[self.card.name]?.append(ticket)
                    
                    self.tix.append(ticket)
                    self.tableView.reloadData()
                    
                    save()
                    
                    var plural = ""
                    if ticket.val > 1
                    {
                        plural = "s"
                    }
                    
                    let success = UIAlertController(title: "Code Redeemed!", message: "This ticket is worth \(ticket.val) point\(plural).", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "See Rewards", style: .default, handler:
                    {   _ in
                        self.goToView(withIdentifier: "RewardVC", handler:
                        {   (view) in
                            if let rewardVC = view as? RewardsVC
                            {
                                rewardVC.card = self.card
                            }
                        })
                    }))
                    success.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(success, animated: true, completion: nil)
                }
                else
                {
                    let failure = UIAlertController(title: "Invalid Code.", message: nil, preferredStyle: .alert)
                    failure.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(failure, animated: true, completion: nil)
                }

            }
        }))
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tix.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticket", for: indexPath)
        let ticket = tix[indexPath.row]
        
        cell.textLabel?.text = ticket.code
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let date = formatter.string(from: ticket.date)
        cell.detailTextLabel?.text = "Redeemed on \(date). Worth \(ticket.val) points."
        
        return cell
    }
}
