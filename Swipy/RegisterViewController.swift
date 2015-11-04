//
//  RegisterViewController.swift
//  SwipyUK
//
//  Created by Niklas Olsson on 12/09/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnWoman: UIButton!
    @IBOutlet weak var btnMan: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtYearOfBirth: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var warningAlert: BPCompatibleAlertController!
    
    var sexSelected = ""
    var kbHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        setupTextFields()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onbtnBackClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onbtnConnectClicked(sender: AnyObject) {
    }
    
    @IBAction func onbtnSexClicked(sender: AnyObject) {
        self.view.endEditing(true)
        
        if sender.tag == 10 {
            sexSelected = "f"
            btnWoman.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            btnMan.backgroundColor = UIColor.clearColor()
        } else if sender.tag == 11 {
            sexSelected = "m"
            btnWoman.backgroundColor = UIColor.clearColor()
            btnMan.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        }
    }
    
    @IBAction func onbtnRegisterClicked(sender: AnyObject) {
        self.view.endEditing(true)
        
        if sexSelected == "" {
            warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please select your gender.", comment: ""), alertStyle: .Alert)
            warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("OK", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            }))
            warningAlert.presentFrom(self, animated: true, completion: { () -> Void in
            })
            return
        }
        
        if txtEmail.text == "" || txtUsername.text == "" || txtPassword.text == "" {
            warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please fill in the fields.", comment: ""), alertStyle: .Alert)
            warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("OK", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            }))
            warningAlert.presentFrom(self, animated: true, completion: { () -> Void in
            })
            return
        }
        
        Utils.sharedInstance.showHUD(self.view)
        
        let objSignUpDictionary:[String:String] = ["email":txtEmail.text, "username":txtUsername.text, "gender":"m", "password":txtPassword.text, "repassword":txtPassword.text]
        
        APIClient.sharedInstance.regiserUserFromApp(objSignUpDictionary, success: { (registerInfo: [String : AnyObject]) -> Void in
            print("response: " + registerInfo.description)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                Utils.sharedInstance.hideHUD()
                
                var revealVC = self.storyboard?.instantiateViewControllerWithIdentifier("RevealViewController") as! SWRevealViewController
                self.presentViewController(revealVC, animated: true, completion: nil)
            })
            
            }) { (error: NSError!) -> Void in
                print("Error: " + error.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Utils.sharedInstance.hideHUD()
                    
                    self.warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Something went wrong", comment: ""), message: NSLocalizedString("You have failed to sign up.", comment: ""), alertStyle: .Alert)
                    self.warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Try Again", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
                    }))
                    self.warningAlert.presentFrom(self, animated: true, completion: { () -> Void in
                    })
                })
        }
        
    }
    
    /**
    * Called when the user click on the view (outside the UITextField).
    */
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // Helpers
    func setupTextFields() {
        var listOfItems = [" Username", " Year of Birth", " E-Mail", " Password"]
        
        for var index = 100; index < 104; index++ {
            if let txtField = self.view.viewWithTag(index) as? UITextField {
                var itemLabel = UILabel(frame: CGRectMake(0, 0, 110.0, txtField.frame.height))
                itemLabel.font = UIFont.boldSystemFontOfSize(13)
                itemLabel.text = listOfItems[index - 100]
                
                txtField.leftView = itemLabel
                txtField.leftViewMode = UITextFieldViewMode.Always
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    // UITextField delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
