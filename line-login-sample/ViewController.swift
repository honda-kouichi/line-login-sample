//
//  ViewController.swift
//  line-login-sample
//
//  Created by kouichi honda on 2015/12/11.
//  Copyright © 2015年 kouichi honda. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    private let adapter = LineAdapter.adapterWithConfigFile()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "authorizationDidChange:",
            name: LineAdapterAuthorizationDidChangeNotification,
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authorizationDidChange(notification: NSNotification)
    {
        let adapter = notification.object as! LineAdapter
        
        if(adapter.authorized)
        {
            alert("Login success!", message: "")
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        if let error = notification.userInfo?["error"] as? NSError
        {
            alert("Login error!", message: error.localizedDescription)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func alert(title: String, message: String)
    {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    @IBAction func loginWithLINEButtonTouchUpInside(sender: UIButton)
    {
        if(adapter.authorized)
        {
            alert("Already authorized", message: "")
            return
        }
        
        if(!adapter.canAuthorizeUsingLineApp)
        {
            alert("LINE is not installed", message: "")
            return
        }
        adapter.authorize()
    }

    @IBAction func loginInAppButtonTouchUpInside(sender: UIButton)
    {
        if(adapter.authorized)
        {
            alert("Alredy authorized", message: "")
            return
        }
        
        let viewController = LineAdapterWebViewController(
            adapter: adapter,
            withWebViewOrientation: kOrientationAll)
        viewController.navigationItem.leftBarButtonItem = LineAdapterNavigationController.barButtonItemWithTitle(
            "Cancel", target: self, action: "cancel:")
        let navigationController = LineAdapterNavigationController(rootViewController: viewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tryApiButtonTouchUpInside(sender: UIButton)
    {
        if(!adapter.authorized)
        {
            alert("Login first!", message: "")
            return
        }
        
        adapter.getLineApiClient().getMyProfileWithResultBlock {[unowned self] (profile, error) -> Void in
            if error != nil
            {
                self.alert("Error occured!", message: error.localizedDescription)
                return
            }
            
            let displayName = profile["displayName"] as! String
            self.alert("Your name is \(displayName)", message: "")
        }
    }
}

