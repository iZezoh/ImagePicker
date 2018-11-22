//
//  ViewController.swift
//  ImagePicker
//
//  Created by Ziyad Alamri on 12/11/2018.
//  Copyright © 2018 Ziyad Alamri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    // Declaring UI elements to be accessible in code
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var camButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.blue,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): 4.5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        
        // Set topText attributes and delegate
        topText.text = "TOP"
        topText.textAlignment = .center
        topText.delegate = self
        topText.defaultTextAttributes = self.memeTextAttributes
        
        // Set bottomText attributes and delegate
        bottomText.text = "BOTTOM"
        bottomText.textAlignment = .center
        bottomText.delegate = self
        bottomText.defaultTextAttributes = self.memeTextAttributes
        
        // Disable camera if device does not have camera (Simulator)
        camButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Disable Share and Save until photo is done
        if imageView.image != nil {
            shareButton.isEnabled = true
            saveButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
            saveButton.isEnabled = false
        }
        
    } // End of viewWillAppear
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
} // End of ViewController class


// MARK: UIImagePickerControllerDelegate ,,,
// This will handle the PickerController
extension ViewController : UIImagePickerControllerDelegate {
    
    // This function allows choosing picture from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    } // End of pickAnImageFromAlbum
    
    
    // This function allows access camera and take a photo
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    } // End of pickAnImageFromCamera
    
    
    // This function assigns the selected photo and displays it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    } // End of imagePickerController
    
    
    // Handling cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    } // End of imagePickerControllerDidCancel
    
} // End of UIImagePickerControllerDelegate Extension




// MARK: UITextFieldDelegate ,,,
// This will handle the textFields
extension ViewController : UITextFieldDelegate {
    
    // Clear default texts
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        
    } // End of textFieldDidBeginEditing
    
    
    // Change the return key on keyboard to done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.returnKeyType = .done
        textField.resignFirstResponder()
        return true
    } // End of textFieldShouldReturn
    
} // End of UITextFieldDelegate Extension


// MARK: Meme Func ,,,
// This is for Meme Functionality
extension ViewController {
    
    @IBAction func save(_ sender: Any) {
        // Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        let img = generateMemedImage()
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        toolBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false

        return memedImage
    }
    
    @IBAction func shareAction() {
        
        let items = [generateMemedImage()]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        ac.completionWithItemsHandler
        present(ac, animated: true)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

// MARK: Meme Struct ,,,
struct Meme {
    var topText: String?
    var bottomText: String?
    var originalImage: UIImage?
    var memedImage: UIImage?
}
