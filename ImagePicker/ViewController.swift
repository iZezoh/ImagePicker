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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        
        // Setup textfields attributes and delegate
        setupTextField(tf: topText, text: "TOP")
        setupTextField(tf: bottomText, text: "BOTTOM")
        
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
    
    
    // This function set up the text fields to be white with black boarders and centralized
    func setupTextField(tf: UITextField, text: String) {
        tf.defaultTextAttributes = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -1]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = self
    } // End of setupTextField
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // move the screen up when the keyboard is covering the textfield
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    
    // Return the screen to the normal position after hiding the keyboard
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    
    // This method gets the height of the keyboard to move the screen up so the textfield does not
    // get covered
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
} // End of ViewController class



// ================================================================= //
// MARK: UIImagePickerControllerDelegate ,,,
// This will handle the PickerController
extension ViewController : UIImagePickerControllerDelegate {
    
    
    // This function allows access camera and take a photo
    @IBAction func chooseImageFromCameraOrPhoto(_ sender: UIButton) {
        var source : UIImagePickerController.SourceType
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        if sender.tag == 0 {
            source = .photoLibrary
        } else {
            source = .camera
        }
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
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





// ================================================================= //
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





// ================================================================= //
// MARK: Meme Func ,,,
// This is for Meme Functionality
extension ViewController {
    
    // This method saves the photo
    @IBAction func save() {
        // Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        UIImageWriteToSavedPhotosAlbum(meme.memedImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    // This method hide navbar and toolbar to save the whole screen with texts as a single image
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        toolBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        let temp = self.view.backgroundColor
        self.view.backgroundColor = UIColor.black
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.view.backgroundColor = temp

        return memedImage
    }
    
    // This method create the meme and present UIActivityViewController to share the meme
    @IBAction func shareAction() {
        let items = [generateMemedImage()]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(ac, animated: true)
    }
    
    // Got this code from internet to save image to album
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
    } // End of image func
    
} // End of ViewController Extension

