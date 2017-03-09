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
    var card: PunchCard!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard card != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "Active Codes"
        }
        else if section == 1
        {
            return "Rewards"
        }
        return ""
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        //0 = Active Codes
        //1 = Rewards
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return card.codes.count
        }
        else if section == 1
        {
            return card.rewards.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "code", for: indexPath)
        
        if indexPath.section == 0
        {
            let code = [String](card.codes.keys)[indexPath.row]
            cell.textLabel?.text = code
            
            if let values = card.codes[code]
            {
                let usesText = "Uses: \(values["uses"]!)"
                let valueText = "Value: \(values["value"]!)"
                cell.detailTextLabel?.text = "\(usesText)\n\(valueText)"
            }
        }
        else if indexPath.section == 1
        {
            let reward = [String](card.rewards.keys)[indexPath.row]
            cell.textLabel?.text = reward
            
            let price = [Int](card.rewards.values)[indexPath.row]
            cell.detailTextLabel?.text = "\(price) tickets"
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
