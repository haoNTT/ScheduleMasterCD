//
//  SignupViewController.swift
//  ScheduleMaster
//
//  Created by Haonan Tian on 5/12/20.
//  Copyright © 2020 Haonan Tian. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class SignupViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var currentUser: Users?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if let safeUsername = self.userNameField.text {
            if let safePassword = self.passwordField.text {
                if safePassword.count < 6 {
                    self.registerAlert(with: "Password must be at least 6 characters long")
                } else {
                    Auth.auth().createUser(withEmail: safeUsername, password: safePassword) { (result, error) in
                        if error != nil {
                            self.registerAlert(with: error!.localizedDescription)
                            return
                        } else {
//                            print(result?.user.email ?? "None")
                            let newUser = Users(context: self.context)
                            newUser.name = result?.user.email!
                            self.currentUser = newUser
                            self.performSegue(withIdentifier: "SignupToCategory", sender: self)
                        }
                    }
                }
            } else {
                self.registerAlert(with: "Invalid password")
            }
        } else {
            self.registerAlert(with: "Invalid username")
        }
    }
    
    func registerAlert(with message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set the user variable in the category class
        let destinationVC = segue.destination as! CategoryTableViewController
        if let safeUser = self.currentUser {
            destinationVC.currUser = safeUser
        }
    }
    
}
