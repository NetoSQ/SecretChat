//
//  SingInViewController.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 29/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class SingInViewController: UIViewController {

    private let segueContactos = "goToContactos"
    
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func btnLogIn(_ sender: Any) {
        
        if txtUser.text != "" && txtPassword.text != "" {
            
            Autentificacion.Instance.login(withEmail: txtUser.text!, password: txtPassword.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.alertUser(title: "Problem With Authentication", message: message!);
                } else {
                    
                    self.txtUser.text = "";
                    self.txtPassword.text = "";
                    
                    self.performSegue(withIdentifier: "goToContactos", sender: nil);
                    
                }
                
            })

            
        } else {
            self.alertUser(title: "Problema Con la autentificacion", message: "No hay nada!")
        }
        
        
    }
    
    @IBAction func btnSignIn(_ sender: Any) {
        
        if txtUser.text != "" && txtPassword.text != "" {
            
            Autentificacion.Instance.signUp(withEmail: txtUser.text!, password: txtPassword.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.alertUser(title: "Problem With Creating A New User", message: message!);
                } else {
                    
                    self.txtUser.text = "";
                    self.txtPassword.text = "";
                    
                    self.performSegue(withIdentifier: self.segueContactos, sender: nil);
                }
                
            })
            
            
            
        } else {
            alertUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields");
        }
    }
    
    private func alertUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Autentificacion.Instance.isLoggedin() {
            performSegue(withIdentifier: self.segueContactos, sender: nil);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
