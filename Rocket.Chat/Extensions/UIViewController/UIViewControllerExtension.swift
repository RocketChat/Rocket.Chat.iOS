//
//  UIViewControllerExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 14/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import ObjectiveC

private var viewScrollViewAssociatedKey: UInt8 = 0

protocol MediaPicker: AnyObject { }

extension MediaPicker where Self: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func openCamera(video: Bool = false) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return assertionFailure("Device camera is not availbale")
        }

        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.mediaTypes = video ? [kUTTypeMovie as String] : [kUTTypeImage as String]
        imagePicker.cameraCaptureMode = video ? .video : .photo
        self.present(imagePicker, animated: true, completion: nil)
    }

    func openPhotosLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .savedPhotosAlbum

        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
            picker.mediaTypes = mediaTypes
        }

        present(picker, animated: true, completion: nil)
    }
}

extension MediaPicker where Self: UIViewController & DrawingControllerDelegate {
    func openDrawing() {
        let storyboard = UIStoryboard(name: "Drawing", bundle: Bundle.main)

        if let controller = storyboard.instantiateInitialViewController() as? UINavigationController {

            if let drawingController = controller.viewControllers.first as? DrawingViewController {
                drawingController.delegate = self
            }

            present(controller, animated: true, completion: nil)
        }
    }
}

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

    @objc internal func keyboardWillShow(_ notification: Foundation.Notification) {
        let userInfo = notification.userInfo
        let value = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let rawFrame = value?.cgRectValue ?? CGRect.zero
        let duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] ?? 0
        let scrollView = self.scrollViewInternal

        UIView.animate(
            withDuration: (duration as AnyObject).doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                guard let insets = scrollView?.contentInset else { return }
                var newInsets = insets
                newInsets.bottom = rawFrame.height

                scrollView?.contentInset = newInsets
                scrollView?.scrollIndicatorInsets = newInsets
        },
            completion: nil
        )
    }

    @objc internal func keyboardWillHide(_ notification: Foundation.Notification) {
        let userInfo = notification.userInfo
        let duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] ?? 0
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

extension UIViewController {

    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }

    static func instantiateFromNib() -> Self? {
        func instanceFromNib<T: UIViewController>() -> T? {
            return nib.instantiate() as? T
        }

        return instanceFromNib()
    }

}
