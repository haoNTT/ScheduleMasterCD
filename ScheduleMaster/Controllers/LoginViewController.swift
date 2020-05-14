//
//  LoginViewController.swift
//  ScheduleMaster
//
//  Created by Haonan Tian on 5/12/20.
//  Copyright © 2020 Haonan Tian. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var loggedinUser: Users?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let safeUser = self.userNameField.text, let safePassword = self.passwordField.text {
            Auth.auth().signIn(withEmail: safeUser, password: safePassword) { (result, error) in
                if error != nil {
                    self.loginAlert(with: error!.localizedDescription)
                } else {
                    //print(result?.user.email ?? "Fail to load name")
                    let newUser = Users(context: self.context)
                    newUser.name = safeUser
                    self.loggedinUser = newUser
                    self.performSegue(withIdentifier: "LoginToCategory", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CategoryTableViewController
        if let safeUser = self.loggedinUser {
            destinationVC.currUser = safeUser
        }
    }
    
    func loginAlert(with message: String) {
        let alert = UIAlertController(title: "Fail to log in", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}
