//
//  DataBase.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 30/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol FetchData: class {
    func dataRecibida(contactos: [Contacto])
}

class DataBase {

    private static let _instance = DataBase()
    
    weak var delegate: FetchData?
    
    private init() {}
    
    static var Instance: DataBase{
        return _instance
    }
    
    var dbReference: DatabaseReference{
        return Database.database().reference()
    }
    
    var contactosReferencia: DatabaseReference{
        return dbReference.child(Constantes.contacts)
    }
    
    var mensajesReferencia: DatabaseReference{
        return dbReference.child(Constantes.messages)
    }
    
    var mensajesMediaReferencia: DatabaseReference{
        return dbReference.child(Constantes.mediaMessages)
    }
    
    var storageReferencia: StorageReference {
        return Storage.storage().reference(forURL: "gs://secretchat2-cd36b.appspot.com/")
    }
    
    var imageReferencia: StorageReference {
        return storageReferencia.child(Constantes.imageStorage)
    }
    
    var videoReferencia: StorageReference {
        return storageReferencia.child(Constantes.videoStorage)
    }
    
    func saveUser(withID: String, email: String, password: String){
        let data: Dictionary<String, Any> = [Constantes.email: email, Constantes.password: password]
        
        contactosReferencia.child(withID).setValue(data)
        
    }
    
    func getContacts(){
        contactosReferencia.observeSingleEvent(of: DataEventType.value) {
            (snapshot: DataSnapshot) in
            var contactos = [Contacto]()
            
            if let misContactos = snapshot.value as? NSDictionary{
                for (key, value) in misContactos {
                    if let contactData = value as? NSDictionary{
                        if let email = contactData[Constantes.email] as? String{
                            let id = key as! String
                            let nuevoContacto = Contacto(id: id, name: email)
                            contactos.append(nuevoContacto)
                        }
                        
                    }
                }
            }
            self.delegate?.dataRecibida(contactos: contactos)
        }
        
    }
    
}


























