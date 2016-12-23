//
//  TTTImageView.swift
//  TicTacToe
//
//  Created by Anirudh Natarajan on 12/22/16.
//  Copyright © 2016 Kodikos. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {
    
    var player:String?
    var activated:Bool! = false
    
    func setPlayer (p:String){
        self.player = p
        
        if activated == false{
            if self.player == "x"{
                self.image = UIImage(named: "x")
            }else{
                self.image = UIImage(named: "o")
            }
            activated = true
        }
        
    }
}
