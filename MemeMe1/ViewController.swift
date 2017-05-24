//
//  ViewController.swift
//  MemeMe1
//
//  Created by Mark Jainchell on 5/22/17.
//  Copyright © 2017 Mark Jainchell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIToolbarDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbarMenu: UIToolbar!
    @IBOutlet weak var navbarMenu: UINavigationBar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var takeNewPicture: UIBarButtonItem!
    @IBOutlet weak var chooseFromAlbum: UIBarButtonItem!
    @IBOutlet weak var shareMeme: UIBarButtonItem!

    let imagePicker = UIImagePickerController()
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0]
    
    func memeTextStyle() {
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.text = "TOP TEXT"
        bottomTextField.text = "BOTTOM TEXT"
        topTextField.tag = 1
        bottomTextField.tag = 2
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memeTextStyle()
        checkForCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    // MARK: Check if a camera is available and adjust button
    
    func checkForCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.takeNewPicture.isEnabled = true
        } else {
            self.takeNewPicture.isEnabled = false
        }
    }
    
    // MARK: Adjusting keyboard position
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    // Shruti Choksi provided assistance regaridng using a conditional for the following two functions.
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
           view.frame.origin.y = 0
        }
    }

    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Managing defaut text in text fields
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            if textField.text == "TOP TEXT" {
                textField.text = ""
            }
        } else if textField.tag == 2 {
            if textField.text == "BOTTOM TEXT" {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            if textField.text == "" {
                textField.text = "TOP TEXT"
            }
        } else if textField.tag == 2 {
            if textField.text == "" {
                textField.text = "BOTTOM TEXT"
            }
        }
    }
    
    // MARK: Selecting an Image or taking a photo
    
    @IBAction func choosePictureFromAlbum(_ sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func takeNewPicture(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        } else {
            NSLog("NO CAMERA")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Save and Share the Meme Actions
    
    func saveTheMeme() {
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        
        // Shruti Choksi provided assistance regaridng how to initialize and use this variable.
        let memeAppDelegate = UIApplication.shared.delegate as! AppDelegate
        memeAppDelegate.meme = meme
    }
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
       
        let memeToShare = [generateMemedImage()] as [Any]
        let showShareScreen = UIActivityViewController(activityItems: memeToShare , applicationActivities: nil)
        present(showShareScreen, animated: true, completion: nil)
        saveTheMeme()
    }
    
    // MARK: Generating Memed Image

    func generateMemedImage() -> UIImage {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        navbarMenu.isHidden = true
        toolbarMenu.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(false, animated: false)
        navbarMenu.isHidden = false
        toolbarMenu.isHidden = false
        
        return memedImage
    }

}

