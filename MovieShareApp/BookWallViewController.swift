//
//  BookWallViewController.swift
//  MovieShareApp
//
//  Created by Olaf Kroon on 07/12/16.
//  Copyright © 2016 Olaf Kroon. All rights reserved.
//
//  BookWallViewController.swift gets books of users from the firebase database and presents
//  them in a table. Users can delete, reserve and add books to the table.

import UIKit
import Firebase
import MGSwipeTableCell


class BookWallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var bookTitle: UITextField!
    @IBOutlet weak var addBookButton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    
    let db = DatabaseHelper()
    var posts = [Post]()
    
    // Initialise a global index variable so the prepareForSegue function can acces the cell index. 
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // When the view is initialised or when something is added to the database reload all data.
        let dataBaseref = FIRDatabase.database().reference()
        let dataId = dataBaseref.child("posts"); dataId.queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            let ref = snapshot.ref
            let parentId = ref.key
            let value = snapshot.value as? NSDictionary
            let dataTitle = value!["title"] as! String
            let dataEmail = value!["email"] as! String
            let dataReserved = value!["reserved"] as! Bool
            
            
            let postValue = Post(email: dataEmail, reserved: dataReserved, title: dataTitle)
            postValue.parent = parentId
            
            self.posts.insert(postValue, at: 0)
           
            self.Tableview.reloadData()
            
        })
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentUser = FIRAuth.auth()?.currentUser
            let cellUser = posts[indexPath.row].email
                if cellUser == currentUser?.email {
                    db.delete(parentId: posts[indexPath.row].parent, index: indexPath.row, posts: &posts)
                tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "You can only delete your own books!", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        self.performSegue(withIdentifier: "nextView", sender: nil)
        
    }
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextView" {
            let destination: BookDetailViewController = segue.destination as! BookDetailViewController
            destination.segueTitle = posts[index].title
        } else if segue.identifier == "previousView" {
            
            let destination: ViewController = segue.destination as! ViewController
            
        }
    }

   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

         return self.posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookWallTableViewCell
        
            cell.title.text = posts[indexPath.row].title
        
            cell.emailOfOwner.text = "From : "+posts[indexPath.row].email
        
            if posts[indexPath.row].reserved == true {
        
                    cell.accessoryType = .checkmark
            } else {
        
                    cell.accessoryType = .none
        
            }
        
        cell.leftButtons = [MGSwipeButton(title: "Reserve",backgroundColor: UIColor.blue, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            self.db.updateReserved(index: indexPath.row, posts: &self.posts)
            if self.posts[indexPath.row].reserved == true {
                cell.accessoryType = .checkmark
            } else {
            cell.accessoryType = .none
            }

            return true
        })]
        cell.leftSwipeSettings.transition = MGSwipeTransition.rotate3D  
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func logUserOut(_ sender: Any) {
        if logOut.isTouchInside {
            let firebaseAuth = FIRAuth.auth()
            
            // Sign user out from firebase and delete his data from the userdefaults to disable autologin.
            do {
                try firebaseAuth?.signOut()
                UserDefaultsClass.sharedInstance.defaults.removeObject(forKey: "email")
                UserDefaultsClass.sharedInstance.defaults.removeObject(forKey: "password")
                print("SIGNED OUT")
                self.performSegue(withIdentifier: "previousView", sender: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
        }
    }
    
    @IBAction func addBook(_ sender: Any) {
        if addBookButton.isTouchInside {
            if bookTitle.text == "" {
                let alert = UIAlertController(title: "please Enter a title", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                db.post(bookTitle: bookTitle.text!)
                bookTitle.text = ""
            }
        }
    }
}


