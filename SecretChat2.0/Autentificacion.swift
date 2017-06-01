//
//  Autentificacion.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 29/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginErrorCode {
    static let invalidEmail = "Usuario no existente";
    static let wrongPassword = "Contrasena Incorrecta";
    static let conectingProblem = "No Conexion";
    static let userNotFound = "Usuario no existente, registralo";
    static let userAlreadyInUse = "Usuario Existente";
    static let weakPassword = "Contrasena Debil, debe ser de minimo 6 caracteres";
}

class Autentificacion {
    
    private static let _instance = Autentificacion();
    
    static var Instance: Autentificacion {
        return _instance;
    }

    var userName = ""
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            } else {
                loginHandler?(nil);
            }
            
        });
        
    } // login func
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            } else {
                
                if user?.uid != nil {
                    
                    // Guardar bato en BD
                    DataBase.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    // login 
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler);
                
                }
            }
            
        });
        
    } // sign up func
    
    func isLoggedin() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do{
                try Auth.auth().signOut();
                return true
            } catch{
                return false
            }
        }
        return true
    } // fin de Logut
    
    func userID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?){
        
        if let errCode = AuthErrorCode(rawValue: err.code){
            switch errCode {
            case .wrongPassword:
                loginHandler?(LoginErrorCode.wrongPassword)
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.invalidEmail)
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.userNotFound)
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.userAlreadyInUse)
                break;
            case .weakPassword:
                loginHandler?(LoginErrorCode.weakPassword)
                break;
            default:
                break;
            }
        }
    
    }

}
