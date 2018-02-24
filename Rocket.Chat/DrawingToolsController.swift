import UIKit
import Photos
import MobileCoreServices
import RealmSwift
import SlackTextViewController
import SimpleImageViewer



extension DrawingViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if let imagePicked =  info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.selectedImage = imagePicked
            self.imageView.image = selectedImage
            dismiss(animated: true,completion:  nil )
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil )
    }
    func shareDrawingClicked1() {
        if self.imageView.image != nil  {
        ChatViewController.toUploadPic = self.imageView.image
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "goback", sender: nil)
        }
        else {
            alert(title: "chat.upload.empty", message: "chat.upload.nothing")
        }
    }

   func saveClicked1() {
        let actionSheet = UIAlertController(title: "chat.upload.choice_pick", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "chat.upload.import", style: .default, handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "chat.upload.tosave", style: .default, handler: { (_) in
            if let image = self.imageView.image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "global.cancel", style: .default, handler: nil ))
        present(actionSheet, animated: true, completion: nil)
    }
    func resetClicked1() {
        imageView.image = nil
    }
    func swapToolClicked1() {
        if !isdrawing {
            swapTool.setImage(#imageLiteral(resourceName: "erase") , for: .normal)
            tool.backgroundColor =  UIColor.clear
            color = lastColor
            brushSize = 5.0
        } else {
            swapTool.setImage(#imageLiteral(resourceName: "brush"), for: .normal)
            lastColor = color
            color = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            brushSize = 30.0
        }
        isdrawing = !isdrawing
    }
}
