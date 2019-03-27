//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray :[Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell",bundle:nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell",for:indexPath) as! CustomMessageCell
        cell.messageBackground.layer.masksToBounds = true
        cell.messageBackground.layer.cornerRadius = 10
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].name
//        let senderEmail = messageArray[indexPath.row].sender  //Email
        let uuid = messageArray[indexPath.row].uuid
        
        
        _ = Database.database().reference().child("users").child(uuid).observe(.value, with: {(snapshot) in
            let sv = snapshot.value as! Dictionary<String,String>
            guard let userProfileImg = sv["profileImgURL"] else {return}
            cell.avatarImageView.loadImgUsingCache(userProfileImg: userProfileImg)
//            let url =  URL(string: userProfileImg)
//            let request = NSMutableURLRequest(url:url!)
//            request.httpMethod = "GET"
//
//            let session = URLSession.shared
//
//            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {
//                (data, response, error) in
//                if error != nil {
//                    return
//                }
//                DispatchQueue.main.async {
//                    cell.avatarImageView.image = UIImage(data: data!)
//                }
//            }).resume()
        })
        
        

        
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email as String! {
            //Message sent by loggenin user
//            cell.avatarImageView.image = UIImage(named:"egg")
            cell.avatarImageView.backgroundColor = UIColor.flatPowderBlue()
            cell.avatarImageView.layer.masksToBounds = true
            cell.avatarImageView.layer.cornerRadius = 25
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }else{
//            cell.avatarImageView.image = UIImage(named:"ny")
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.avatarImageView.layer.masksToBounds = true
            cell.avatarImageView.layer.cornerRadius = 25
            cell.messageBackground.backgroundColor = UIColor.flatBlack()
        }
        
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.separatorStyle = .none
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight  = 120.0
        
    }

    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0, delay: 0,options: .curveEaseOut, animations: {
            self.heightConstraint.constant = 405
            self.view.layoutIfNeeded()
        }, completion:{(completed) in
           let indexPath = NSIndexPath(row: self.messageArray.count-1, section: 0)
            if self.messageArray.count > 0 {
                self.scrollToBottom()
            }
        })
        
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
         self.heightConstraint.constant = 50
         self.view.layoutIfNeeded()
        }
    }
    
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let userDB = Database.database().reference().child("users").child(Auth.auth().currentUser?.uid as String!)
        userDB.observe(.value, with: { (snapshot) in
            let sv = snapshot.value as! Dictionary<String,String>
            guard let uname = sv["name"] else {return}
            self.saveMessages(name: uname)
        })
    }
    
    func saveMessages(name:String){
        let messageDB = Database.database().reference().child("Messages")
        let messageDict = ["Name": name,"Sender": Auth.auth().currentUser?.email,"MessageBody":messageTextfield.text!,"UID":Auth.auth().currentUser?.uid]
        
        messageDB.childByAutoId().setValue(messageDict) {
            (error,reference) in
            if error != nil {
                print(error)
            }else {
                print("Messages saved")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        } //Saving messages in Dictionary with ID
    }
    
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded, with:{ (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let name = snapshotValue["Name"]!
            let uuid = snapshotValue["UID"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            message.name = name
            message.uuid = uuid
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
            if self.messageArray.count > 0 {
                self.scrollToBottom() }
        })
        
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            SVProgressHUD.show()
            try Auth.auth().signOut()
            SVProgressHUD.dismiss()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("Error")
        }
    }
    


}
