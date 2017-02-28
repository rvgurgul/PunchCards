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
     
     UUIDUUID-UUID-UUID-UUID-UUIDUUIDUUID
     A7988A16-6C89-4811-93D6-BA5A1E048ED9

     */
    
    var punchCards = [PunchCard]()
    
    var userID: String?
    {
        return UserDefaults.standard.string(forKey: "id")
    }
    
    var ref: FIRDatabaseReference
    {
        return FIRDatabase.database().reference()
    }
    
    var handle: FIRDatabaseHandle?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        cardCollection.dataSource = self
        cardCollection.delegate = self
        
        if let saved = UserDefaults.standard.array(forKey: "saved") as? [PunchCard]
        {
            punchCards = saved
        }
        
        UserDefaults.standard.removeObject(forKey: "id")
        if userID == nil
        {
            UserDefaults.standard.set(UUID().uuidString, forKey: "id")
            //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setUsername), userInfo: nil, repeats: false)
        }
    
        handle = ref.child("test").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? NSDictionary
            {
                let username = item["admin"] as? String ?? ""
                print(username)
                let codes = item["codes"] as? NSDictionary
                print(codes!)
                let rewards = item["rewards"] as? NSDictionary
                print(rewards!)
                let points = item["points"] as? NSDictionary
                print(points!)
                let image = item["image"] as? String ?? ""
                print(image)
                
                self.punchCards.append(PunchCard(name: username, data: image, rewards: rewards as! [String : Int]))
            }
            
        })
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PunchCardCell
        cell.imageCell.image = punchCards[indexPath.item].image
        cell.nameLabel.text = punchCards[indexPath.item].name
        //cell.detailLabel.text = "\(punchCards[indexPath.item].punches.count)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return punchCards.count
    }
    
    func set(_ key: String, to val: Any) {ref.updateChildValues([key: val])}
    
    func get(_ key: String) -> Any?
    {
        var result: Any? = nil
        ref.child(key).observeSingleEvent(of: .value, with:
        {   (snapshot) in
            result = snapshot.value
        })
        {   (error) in
            print("ERROR: \(error.localizedDescription)")
        }
        return result
    }
    
    func setUsername()
    {
        let alert = UIAlertController(title: "Choose a username.", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler:
        {   _ in
            if let input = alert.textFields?[0].text
            {
                //if someone already has the username, call setUsername again
                //else set all-users/their UUID to their username
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}
