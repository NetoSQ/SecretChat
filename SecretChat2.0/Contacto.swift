//
//  Contacto.swift
//  SecretChat2.0
//
//  Created by Ernesto Salazar on 30/05/17.
//  Copyright © 2017 DreamTeamCo. All rights reserved.
//

import Foundation

class Contacto{

    private var _name = ""
    private var _id = ""
    
    init(id: String, name: String){
        _id = id
        _name = name
    }
    
    var name: String{
        get{
            return _name
        }
    }
    
    var id: String{
        return _id
    }
    
}
