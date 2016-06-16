//
//  SignUpVC.swift
//  Prey
//
//  Created by Javier Cala Uribe on 20/11/14.
//  Copyright (c) 2014 Fork Ltd. All rights reserved.
//

import UIKit

class SignUpVC: UserRegister {

    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureTextButton() {
        
        subtitleView.text               = "prey account".localized
        titleView.text                  = "SIGN UP".localized
        nameTextField.placeholder       = "username".localized
        emailTextField.placeholder      = "email".localized
        passwordTextField.placeholder   = "password".localized
        
        addDeviceButton.setTitle("CREATE MY NEW ACCOUNT".localized, forState:.Normal)
        changeViewBtn.setTitle("already have an account?".localized, forState:.Normal)
    }
    
    // MARK: Actions
    
    // Show SignIn view
    @IBAction func showSignInVC(sender: UIButton) {
        
        // Get SharedApplication delegate
        guard let appWindow = UIApplication.sharedApplication().delegate?.window else {
            print("error with sharedApplication")
            return
        }
        
        // Get SignUpVC from Storyboard
        if let controller:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("signInVCStrbrd") {
            
            // Set controller to rootViewController
            let navigationController:UINavigationController = appWindow!.rootViewController as! UINavigationController
            
            let transition:CATransition = CATransition()
            transition.type = kCATransitionFade
            navigationController.view.layer.addAnimation(transition, forKey: "")
                        
            navigationController.setViewControllers([controller], animated: false)
        }
    }
    
    // Add device action
    @IBAction override func addDeviceAction(sender: UIButton?) {

        // Check name length
        if nameTextField.text!.characters.count < 1 {
            displayErrorAlert("Name can't be blank".localized, titleMessage:"We have a situation!".localized)
            nameTextField.becomeFirstResponder()
            return
        }
        
        // Check password length
        if passwordTextField.text!.characters.count < 6 {
            displayErrorAlert("Password must be at least 6 characters".localized, titleMessage:"We have a situation!".localized)
            passwordTextField.becomeFirstResponder()
            return
        }
        
        // Check valid email
        if isInvalidEmail(emailTextField.text!, withPattern:emailRegExp) {
            displayErrorAlert("Enter a valid e-mail address".localized, titleMessage:"We have a situation!".localized)
            emailTextField.becomeFirstResponder()
            return
        }

        
        // Show ActivityIndicator
        let actInd              = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.Gray)
        actInd.center           = self.view.center
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()

        // SignUp to Panel Prey
        PreyUser.signUpToPrey(nameTextField.text!, userEmail:emailTextField.text!, userPassword:passwordTextField.text!, onCompletion: {(isSuccess: Bool) in
            
            // LogIn isn't Success
            guard isSuccess else {
                // Hide ActivityIndicator
                dispatch_async(dispatch_get_main_queue()) {
                    actInd.stopAnimating()
                }
                return
            }
            
            // Add Device to Panel Prey
            PreyDevice.addDeviceWith({(isSuccess: Bool) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // Add Device Success
                    guard isSuccess else {
                        // Hide ActivityIndicator
                        actInd.stopAnimating()
                        return
                    }
                    
                    if let resultController = self.storyboard!.instantiateViewControllerWithIdentifier("deviceSetUpStrbrd") as? DeviceSetUpVC {
                        self.presentViewController(resultController, animated: true, completion: nil)
                    }
                }
            })
        })
    }
}
