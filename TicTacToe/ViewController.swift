//
//  ViewController.swift
//  TicTacToe
//
//  Created by Anirudh Natarajan on 12/22/16.
//  Copyright © 2016 Kodikos. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet var fields: [TTTImageView]!
    var currentPlayer:String!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.peerChangedStateWithNotification(_:)), name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleReceivedDataWithNotification(_:)), name: NSNotification.Name(rawValue: "MPC_DidReceiveDataNotification"), object: nil)
        
        setupField()
        currentPlayer = "x"
        
    }
    
    
    @IBAction func connectWithPlayer(_ sender: AnyObject) {
        
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    func peerChangedStateWithNotification(_ notification:Notification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.object(forKey: "state") as! Int
        
        if state != MCSessionState.connecting.rawValue{
            self.navigationItem.title = "Connected"
        }
        
    }
    
    func handleReceivedDataWithNotification(_ notification:Notification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:Data = userInfo["data"] as! Data
        
        do {
            let message = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
            let senderDisplayName = senderPeerId.displayName
            
            if (message.object(forKey: "string") as AnyObject).isEqual("New Game") == true{
                let alert = UIAlertController(title: "TicTacToe", message: "\(senderDisplayName) has started a new Game", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                resetField()
            }else{
                let field:Int? = (message.object(forKey: "field") as AnyObject).integerValue
                let player:String? = message.object(forKey: "player") as? String
                
                if field != nil && player != nil{
                    fields[field!].player = player
                    fields[field!].setPlayer(p: player!)
                    
                    if player == "x"{
                        currentPlayer = "o"
                    }else{
                        currentPlayer = "x"
                    }
                    
                    checkResults()
                    
                }
                
            }
        } catch {
            print(error)
        }
        
        
    }
    
    
    func fieldTapped (_ recognizer:UITapGestureRecognizer){
        let tappedField  = recognizer.view as! TTTImageView
        tappedField.setPlayer(p: currentPlayer)
        
        let messageDict = ["field":tappedField.tag, "player":currentPlayer] as [String : Any]
        
        let messageData:Data
        do {
            messageData = try JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print (error)
        }
        
        //        if error != nil{
        //            println("error: \(error?.localizedDescription)")
        //        }
        
        checkResults()
        
        
    }
    
    
    func setupField (){
        for index in 0 ... fields.count - 1{
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.fieldTapped(_:)))
            gestureRecognizer.numberOfTapsRequired = 1
            
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func resetField(){
        for index in 0 ... fields.count - 1{
            fields[index].image = nil
            fields[index].activated = false
            fields[index].player = ""
        }
        
        currentPlayer = "x"
    }
    @IBAction func newGame(_ sender: AnyObject) {
        resetField()
        
        let messageDict = ["string":"New Game"]
        
        let messageData:Data
        do {
            messageData = try JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print (error)
        }
        
    }
    
    func checkResults(){
        var winner = ""
        
        if fields[0].player == "x" && fields[1].player == "x" && fields[2].player == "x"{
            winner = "x"
        }else if fields[0].player == "o" && fields[1].player == "o" && fields[2].player == "o"{
            winner = "o"
        }else if fields[3].player == "x" && fields[4].player == "x" && fields[5].player == "x"{
            winner = "x"
        }else if fields[3].player == "o" && fields[4].player == "o" && fields[5].player == "o"{
            winner = "o"
        }else if fields[6].player == "x" && fields[7].player == "x" && fields[8].player == "x"{
            winner = "x"
        }else if fields[6].player == "o" && fields[7].player == "o" && fields[8].player == "o"{
            winner = "o"
        }else if fields[0].player == "x" && fields[3].player == "x" && fields[6].player == "x"{
            winner = "x"
        }else if fields[0].player == "o" && fields[3].player == "o" && fields[6].player == "o"{
            winner = "o"
        }else if fields[1].player == "x" && fields[4].player == "x" && fields[7].player == "x"{
            winner = "x"
        }else if fields[1].player == "o" && fields[4].player == "o" && fields[7].player == "o"{
            winner = "o"
        }else if fields[2].player == "x" && fields[5].player == "x" && fields[8].player == "x"{
            winner = "x"
        }else if fields[2].player == "o" && fields[5].player == "o" && fields[8].player == "o"{
            winner = "o"
        }else if fields[0].player == "x" && fields[4].player == "x" && fields[8].player == "x"{
            winner = "x"
        }else if fields[0].player == "o" && fields[4].player == "o" && fields[8].player == "o"{
            winner = "o"
        }else if fields[2].player == "x" && fields[4].player == "x" && fields[6].player == "x"{
            winner = "x"
        }else if fields[2].player == "o" && fields[4].player == "o" && fields[6].player == "o"{
            winner = "o"
        }
        
        if winner != ""{
            let alert = UIAlertController(title: "Tic Tac Toe", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                self.resetField()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



