//
//  Mensajes.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 31/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol MensajeRecibidoDelegate: class {
    func mensajeRecibido(senderID: String, senderName: String, text: String);
    func mediaRecibida(senderID: String, senderName: String, url: String)
}

class Mensajes {
    private static let _instance = Mensajes()
    private init() {}
    
    weak var delegate: MensajeRecibidoDelegate?
    
    static var Instance: Mensajes{
        return _instance
    }
    
    func enviarMensaje(senderID: String, senderName: String, text: String){
        let data: Dictionary<String, Any> = [Constantes.senderID: senderID, Constantes.senderName: senderName, Constantes.text: text]
        DataBase.Instance.mensajesReferencia.childByAutoId().setValue(data)
    }
    
    func enviarMensajeMedia(senderID: String, senderName: String, url: String){
        let data: Dictionary<String, Any> = [Constantes.senderID: senderID, Constantes.senderName: senderName, Constantes.url: url]
        DataBase.Instance.mensajesMediaReferencia.childByAutoId().setValue(data)
    }
    
    func enviarMedia(image: Data?, video: URL?, senderID: String, senderName: String){
        
        if image != nil {
            DataBase.Instance.imageReferencia.child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil) { (metadata: StorageMetadata?, err: Error?) in
                if err != nil {
                    // equis flaca
                } else {
                    self.enviarMensajeMedia(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                }
            }
        } else {
            DataBase.Instance.videoReferencia.child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil) { (metadata: StorageMetadata?, err: Error?) in
                if err != nil {
                    // equis flaca
                } else {
                    self.enviarMensajeMedia(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                }
            }
        }
        
    }
    
    func observarMensajes(){
        DataBase.Instance.mensajesReferencia.observe(DataEventType.childAdded){
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let senderID = data[Constantes.senderID] as? String {
                    if let senderName = data[Constantes.senderName] as? String{
                        if let text = data[Constantes.text] as? String {
                            self.delegate?.mensajeRecibido(senderID: senderID, senderName: senderName, text: text)
                        }
                    }
                }
            }
        }
    }
    
    func observarMedia(){
        DataBase.Instance.mensajesMediaReferencia.observe(DataEventType.childAdded) {
            (snapshot: DataSnapshot) in
        
            if let data = snapshot.value as? NSDictionary {
                if let senderID = data[Constantes.senderID] as? String{
                    if let senderName = data[Constantes.senderName] as? String{
                        if let url = data[Constantes.url] as? String {
                            self.delegate?.mediaRecibida(senderID: senderID, senderName: senderName, url: url)
                        }
                    }
                }
            }
            
        }
    }
}
