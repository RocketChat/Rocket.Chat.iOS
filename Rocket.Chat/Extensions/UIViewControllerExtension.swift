//
//  UIViewControllerExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 14/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveC

private var viewScrollViewAssociatedKey: UInt8 = 0

extension UIViewController {
    
    var scrollViewInternal: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &viewScrollViewAssociatedKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &viewScrollViewAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: Keyboard Handling
    
    func registerKeyboardHandlers(_ scrollView: UIScrollView) {
        self.scrollViewInternal = scrollView
        
        // Keyboard handler
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIViewController.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIViewController.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func keyboardWillShow(_ notification: Foundation.Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let value = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let rawFrame = value.cgRectValue
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!
        let scrollView = self.scrollViewInternal
        
        UIView.animate(
            withDuration: (duration as AnyObject).doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                var insets = scrollView?.contentInset
                insets?.bottom = rawFrame.height
                
                scrollView?.contentInset = insets!
                scrollView?.scrollIndicatorInsets = insets!
        },
            completion: nil
        )
    }
    
    internal func keyboardWillHide(_ notification: Foundation.Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!
        let scrollView = self.scrollViewInternal
        
        UIView.animate(
            withDuration: (duration as AnyObject).doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                let insets = UIEdgeInsets.zero
                scrollView?.contentInset = insets
                scrollView?.scrollIndicatorInsets = insets
        },
            completion: nil
        )
    }
    
}
