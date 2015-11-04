//
//  LoginViewController.swift
//  SwipyUK
//
//  Created by Niklas Olsson on 12/09/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var warningAlert: BPCompatibleAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onbtnBackClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func onConnectFacebook(sender: AnyObject) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func onbtnLoginClicked(sender: AnyObject) {
        self.view.endEditing(true)
        
        if txtEmail.text == "" || txtPassword.text == "" {
            warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please enter username or password.", comment: ""), alertStyle: .Alert)
            warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("OK", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            }))
            warningAlert.presentFrom(self, animated: true, completion: { () -> Void in
            })
            return
        }
        
        Utils.sharedInstance.showHUD(self.view)
        
        let objSignInDictionary:[String:String] = ["email":txtEmail.text, "password":txtPassword.text]
        
        APIClient.sharedInstance.oAuthForLogin(objSignInDictionary, success: { (authInfo: [String : AnyObject]) -> Void in
            print("response: " + authInfo.description)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                Utils.sharedInstance.hideHUD()
                
                var response : [String: AnyObject] = authInfo;
                let loginObj:[String:String] = ["access_token" : "access_token"]
                
                // To Do log in
                APIClient.sharedInstance.loginFromApp(loginObj, success: { (loginInfo: [String : AnyObject]) -> Void in
                    print("response: " + loginInfo.description)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        Utils.sharedInstance.hideHUD()
                        
                        var revealVC = self.storyboard?.instantiateViewControllerWithIdentifier("RevealViewController") as! SWRevealViewController
                        self.presentViewController(revealVC, animated: true, completion: nil)
                    })
                    
                    }) { (error: NSError!) -> Void in
                        print("Error: " + error.localizedDescription)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            Utils.sharedInstance.hideHUD()
                            
                            self.warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Something went wrong", comment: ""), message: NSLocalizedString("You have failed to log in.", comment: ""), alertStyle: .Alert)
                            self.warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Try Again", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
                            }))
                            self.warningAlert.presentFrom(self, animated: true, completion: { () -> Void in
                            })
                        })
                }
            })
            
            }) { (error: NSError!) -> Void in
                print("Error: " + error.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Utils.sharedInstance.hideHUD()
                    
                    self.warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Something went wrong", comment: ""), message: NSLocalizedString("You have failed to log in.", comment: ""), alertStyle: .Alert)
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
