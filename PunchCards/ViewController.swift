//
//  ViewController.swift
//  PunchCards
//
//  Created by Richie Gurgul on 2/21/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    
    @IBOutlet weak var cardCollection: UICollectionView!
    
    /*
     GITHUB:
     https://github.com/rvgurgul/PunchCards

     FIREBASE:
     https://punchcards-14936.firebaseio.com/
     - for each "business" we'll store a user-id (device UUID?), picture, and a list of codes/passwords to redeem punches.
        - codes can have a # of uses or have an expiration date
     
     Punch-Out
     - each punch card will have an image, a name, a goal, and a count
     
     MVP: As a user I want an app that will be a digital punch cards for businesses that store and tracks rewards.
     - punchcards which the user has admin access to have are golden
     - collectionview with each punchcard's image, title, and current punches displayed
        - tap on one to see detailed information/tableview with each punch's date and description
     
     Stretch 1: The app will have an admin and user feature.
     Stretch 2: Punches will be made secure via a password set by admin.
     
     - if you are the admin, the tableview will display the active codes and you can add more
     - if you are a user, the tableview will display the codes you have redeemed
     
     Stretch 3: The punch cards will be 100% customizable based on the business needs.
     -

     Richie's User ID: A7988A16-6C89-4811-93D6-BA5A1E048ED9-RGurgul
     
     */
    
    var punchCards = [PunchCard]()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        <#code#>
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PunchCardCell
        cell.imageCell.image = punchCards[indexPath.item].image
        cell.nameLabel.text = punchCards[indexPath.item].name
        cell.detailLabel.text = "\(punchCards[indexPath.item].punches.count)"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return punchCards.count
    }
    
    var firebaseURL: URL
    {
        return URL(string: "https://punchcards-14936.firebaseio.com/")!
    }
    
    var userID: String
    {
        //If the user already has a custom id, return it
        if let uuid = UserDefaults.standard.string(forKey: "id")
        {
            return uuid
        }
        //Otherwise, generate a new custom id and store it
        else
        {
            let randomID = UUID().uuidString
            UserDefaults.standard.set(randomID, forKey: "id")
            return randomID
        }
    }
    
    var deviceName: String {return UIDevice.current.name}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        cardCollection.dataSource = self
        cardCollection.delegate = self
        
        if let data = try? Data(contentsOf: firebaseURL, options: [])
        {
            parse(JSON(data: data))
        }
        
        if let saved = UserDefaults.standard.array(forKey: "saved") as? [PunchCard]
        {
            punchCards = saved
        }
    }
    
    func parse(_ json: JSON)
    {
    }
    
}

