//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseStorage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = ""
        emailTextfield.text = ""
        passwordTextfield.text = ""
        profileImage.image = UIImage(named: "profile")
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        profileImage.isUserInteractionEnabled = true
        
    }
    
    @objc func handleSelectProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true             // editting and zoom
        present(picker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage :UIImage?
        if let edittedImage = info[.editedImage] as? UIImage{
            selectedImage = edittedImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let profileImageSelected = selectedImage {
            profileImage.image = profileImageSelected
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
        profileImage.image = UIImage(named: "egg")
        dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
  
    @IBAction func registerPressed(_ sender: AnyObject) {
        

        
        //TODO: Set up a new user on our Firbase database
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            (user, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error!", message: "Email ID already in Use", preferredStyle: .alert)
                SVProgressHUD.dismiss()
                self.present(alert,animated: true,completion: nil)
                let restartAction = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in self.viewDidLoad()
                })
                alert.addAction(restartAction)
                print(error!)
            }else{
                //Success
                print("Registeration successful")
                
                storeProfileImage()
                
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
        
        func storeProfileImage(){
            let storageRef = Storage.storage().reference().child("users").child("\(Auth.auth().currentUser!.uid).png")
            if let uploadData = self.profileImage.image!.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    if error != nil {
                        print(error)
                    }
                    storageRef.downloadURL {(url,err) in if err != nil {return }
                    else{
                        let values: [String : AnyObject] = ["name":self.nameTextField.text! as AnyObject,"email":self.emailTextfield.text! as AnyObject,"profileImgURL":url?.absoluteString as AnyObject]
                        registerUserInDB(values:values)
                        }
                    }
                })
            }
        }
        
        func registerUserInDB (values:[String:AnyObject]) {
            let ref = Database.database().reference(fromURL: "https://YOUR_DATABASE_URL.firebaseio.com/")
            let usersRef = ref.child("users").child(Auth.auth().currentUser!.uid)
            usersRef.updateChildValues(values, withCompletionBlock: {
                (err,ref) in
                if err != nil {
                    print(err)
                }
                else{
                    print("Saved Successfully")
                }
            })
        }
        
    }
}



