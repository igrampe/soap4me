//
//  SMSignInViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 17/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SignInViewControllerProtocol: class {
    func signInSucceed()
}

class SMSignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginField: SMSignInTextFiled!
    @IBOutlet weak var passwordField: SMSignInTextFiled!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    weak var delegate: SignInViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.observe(selector: "keyBoardWillChangeWithNotification:", name: UIKeyboardWillChangeFrameNotification)
        self.observe(selector: "keyBoardWillHideWithNotification:", name: UIKeyboardWillHideNotification)
        self.observe(selector: "signInSucceed:", name: SMStateManagerNotification.SignInSucceed.rawValue)
        self.observe(selector: "signInFailed:", name: SMStateManagerNotification.SignInFailed.rawValue)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.stopObserve()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Notifications
    
    //MARK: -Keyboard
    
    func keyBoardWillChangeWithNotification(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.contentInset = contentInset
            if let field = self.activeField {
                let rect: CGRect = CGRectMake(0, field.superview!.frame.origin.y+field.frame.origin.y, self.scrollView.bounds.size.width, field.frame.size.height)
                self.scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }
    
    func keyBoardWillHideWithNotification(notification: NSNotification) {
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.scrollView.contentInset = contentInset
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    //MARK: -SignIn
    
    func signInSucceed(notification: NSNotification) {
        SVProgressHUD.dismiss()
        self.delegate?.signInSucceed()
    }
    
    func signInFailed(notification: NSNotification) {
        var msg: String = NSLocalizedString("Неизвестная ошибка")
        if let error = notification.object as? NSError {
            msg = error.localizedDescription
        }
        SVProgressHUD.showErrorWithStatus(msg)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.loginField {
            self.passwordField.becomeFirstResponder()
        } else if textField == self.passwordField {
            self.passwordField.resignFirstResponder()
            self.signInAction(nil)
        }
        return false
    }
    
    //MARK: IBActions
    
    @IBAction func signInAction(sener: UIButton?) {
        if let login = self.loginField.text, password = self.passwordField.text {
            SMStateManager.sharedInstance.signIn(login, password: password)
            SVProgressHUD.show()
        }
        
    }
}
