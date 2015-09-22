
//
//  profileViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/20/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController

class profileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var languageTextField: UITextField!
    @IBOutlet var scrollview: UIScrollView!
    
    var language = [String()]
    let picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Some languages to add to the pickerview
        language = ["English","Greek","Portuguese"]
        
        //Set username placeholder
        
        
        //Set pickerview's delegate and background color
        picker.delegate = self
        picker.backgroundColor = UIColor.rocketDarkBlueColor()
        
        //Change languageTextField's input to pickerview
        languageTextField.inputView = picker
        
        //Set the languageTextField's placeholder and also set it's tint color to clear color so the text indicator won't be visible
        languageTextField.placeholder = "English"
        languageTextField.tintColor = UIColor.clearColor()
        
        passwordTextField.secureTextEntry = true
        
        //Add tap gesture to scrollview
        let tapScrollView = UITapGestureRecognizer(target: self, action: "touchScrollview")
        scrollview.addGestureRecognizer(tapScrollView)
        
        
        //Set the navigation's title to rocketMainFontColor
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.rocketMainFontColor()]

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Menu button action
    @IBAction func backButton(sender: AnyObject) {
        
        //get the appDelegate
        let appdelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Open the left drawer
        appdelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        
    }
    
    
    //Saving Changes
    @IBAction func saveChangesAction(sender: AnyObject) {
    
        //Close input
        self.view.endEditing(true)
        
        
        //Create alert
        let alert = UIAlertController(title: "Changes saved", message: "Your changes have been saved", preferredStyle: UIAlertControllerStyle.Alert)
        

        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
           //OK action
        }
        
        alert.addAction(OKAction)
    
        presentViewController(alert, animated: true, completion: nil)
        
        
        //TODO: Actually save changes
    
    }
    
    
    //With this editing the language textfield is not possible but we still can interact with it
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == languageTextField) {
            
            return false
            
        }
        else {
            
            return true
            
        }
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        textField.resignFirstResponder()
    }
    
    //MARK: Managing the keyboard
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func touchScrollview() {
        
        self.view.endEditing(true)
        
    }
    
    
    //MARK: UIPICKER
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return language.count
        
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let languageTitleForRow = language[row]
        let myTitle = NSAttributedString(string: languageTitleForRow, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        return myTitle
        
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        languageTextField.placeholder = language[row]
        
    }
    
}
