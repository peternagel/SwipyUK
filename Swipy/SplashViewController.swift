//
//  SplashViewController.swift
//  SwipyUK
//
//  Created by Niklas Olsson on 12/09/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit
import MediaPlayer

class SplashViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var videoView: UIView!
    
    var moviePlayer : MPMoviePlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let
            path = NSBundle.mainBundle().pathForResource("video", ofType:"mp4"),
            url = NSURL(fileURLWithPath: path),
            moviePlayer = MPMoviePlayerController(contentURL: url) {
                self.moviePlayer = moviePlayer
                moviePlayer.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.width / 300.0 * 169.0)
                moviePlayer.prepareToPlay()
                moviePlayer.scalingMode = .AspectFill
                moviePlayer.controlStyle = MPMovieControlStyle.None
                moviePlayer.repeatMode = MPMovieRepeatMode.One
                videoView.addSubview(moviePlayer.view)
        } else {
            debugPrint("Ops, something wrong when playing video.m4v")
        }

        // Do any additional setup after loading the view.
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
//            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
    // Helpers
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    func didFinishPlaying()
    {
        
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
