//
//  ContactosViewController.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 29/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import UIKit

class ContactosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FetchData {

    @IBAction func btnLogout(_ sender: Any) {
        if Autentificacion.Instance.logOut(){
            dismiss(animated: true, completion: nil);
        }
    }
     
    @IBOutlet weak var tvContactos: UITableView!
    
    private var contacto = [Contacto]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataBase.Instance.delegate = self
        DataBase.Instance.getContacts()
        
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func dataRecibida(contactos: [Contacto]) {
        self.contacto = contactos
        
        for contacto in contactos {
            
            if contacto.id == Autentificacion.Instance.userID(){
                Autentificacion.Instance.userName = contacto.name
            }
        }
        
        tvContactos.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if contacto[indexPath.row].id != Autentificacion.Instance.userID(){
            cell.textLabel?.text = contacto[indexPath.row].name
        }
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChat", sender: nil)
    }
    

}
