//
//  ChatViewController.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 30/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SDWebImage

class ChatViewController: JSQMessagesViewController, MensajeRecibidoDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var mensajes = [JSQMessage]()
    
    let picker = UIImagePickerController()
    

    @IBAction func btnAtras(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        Mensajes.Instance.delegate = self
        
        self.senderId = Autentificacion.Instance.userID()
        self.senderDisplayName = Autentificacion.Instance.userName
        
        Mensajes.Instance.observarMensajes()
        Mensajes.Instance.observarMedia()
        
    }
    
    //COLLECTIONVIEW FUNCS
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return mensajes[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mensajes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    //MESSAGES FUNc
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        Mensajes.Instance.enviarMensaje(senderID: senderId, senderName: senderDisplayName, text: text)
        
        // Quita el texto
        finishSendingMessage()
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let mensaje = mensajes[indexPath.item]
        
        if mensaje.senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: #colorLiteral(red: 0.3234693706, green: 0.3234777451, blue: 0.3234732151, alpha: 1))
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "ProfileImg"), diameter: 30)
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = mensajes[indexPath.item]
        
        if msg.isMediaMessage{
            if let mediaItem = msg.media as? JSQVideoMediaItem{
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true, completion: nil)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Multimedia", message: "Selecciona: ", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photos = UIAlertAction(title: "Fotos", style: .default, handler: {
            (alert: UIAlertAction) in
            self.escogerMulti(type: kUTTypeImage)
        })
        let videos = UIAlertAction(title: "Videos", style: .default, handler: {
            (alert: UIAlertAction) in
            self.escogerMulti(type: kUTTypeMovie)
        })
        
        alert.addAction(photos)
        alert.addAction(cancel)
        alert.addAction(videos)
        present(alert, animated: true, completion: nil)
    }
    
    
    // Picker View Func
    
    private func escogerMulti(type: CFString){
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            let data = UIImageJPEGRepresentation(pic, 0.01)
            
            Mensajes.Instance.enviarMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName)
            
        }else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            Mensajes.Instance.enviarMedia(image: nil, video: vidUrl, senderID: senderId, senderName: senderDisplayName)
            
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    //Delegation Funcs
    
    func mensajeRecibido(senderID: String, senderName: String, text: String) {
        self.mensajes.append(JSQMessage(senderId: senderID, displayName: senderName, text: text))
        collectionView.reloadData()
    }
    
    func mediaRecibida(senderID: String, senderName: String, url: String) {
        
        if let mediaURL = URL(string: url) {
            
            do{
            
                let data = try Data(contentsOf: mediaURL)
                if let _ = UIImage(data: data){
                    
                    let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: { (image, data, error, finished) in
                        
                        DispatchQueue.main.async {
                            let foto = JSQPhotoMediaItem(image: image)
                            if senderID == self.senderId {
                                foto?.appliesMediaViewMaskAsOutgoing = true
                            } else {
                                foto?.appliesMediaViewMaskAsOutgoing = false
                            }
                            
                            self.mensajes.append(JSQMessage(senderId: senderID, displayName: senderName, media: foto))
                            self.collectionView.reloadData()

                        }
                        
                    })
                    
                } else{
                    let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true)
                    if senderID == self.senderId{
                        video?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        video?.appliesMediaViewMaskAsOutgoing = false
                    }
                    mensajes.append(JSQMessage(senderId: senderID, displayName: senderName, media: video))
                    self.collectionView.reloadData()
                }
                
            } catch{
            
                
                
            }
            
        }
        
    }
    
}
















