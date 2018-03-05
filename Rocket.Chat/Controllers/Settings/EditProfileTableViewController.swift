//
//  EditProfileTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, MediaPicker {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!
    @IBOutlet weak var avatarButton: UIButton!

    var avatarView: AvatarView = {
        guard let avatarView = AvatarView.instantiateFromNib() else { return AvatarView() }
        avatarView.isUserInteractionEnabled = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.layer.cornerRadius = 15
        avatarView.layer.masksToBounds = true

        return avatarView
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    let api = API.current()
    var isUpdatingUser = false
    var isUploadingAvatar = false
    var isLoading = true
    var avatarFile: FileUpload?
    var user: User? = User() {
        didSet {
            bindUserData()
        }
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAvatarButton()
        fetchUserData()
    }

    // MARK: Setup

    func setupAvatarButton() {
        avatarButton.addSubview(avatarView)
        avatarView.topAnchor.constraint(equalTo: avatarButton.topAnchor).isActive = true
        avatarView.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor).isActive = true
        avatarView.leadingAnchor.constraint(equalTo: avatarButton.leadingAnchor).isActive = true
        avatarView.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor).isActive = true
    }

    func fetchUserData() {
        avatarView.shouldRefreshCache = true

        let meRequest = MeRequest()
        api?.fetch(meRequest, succeeded: { (result) in
            if let errorMessage = result.errorMessage {
                Alert(key: "alert.load_profile_error").withMessage("errorMessage").present(handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                self.user = result.user
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, errored: { (_) in
            Alert(key: "alert.load_profile_error").present(handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
        })
    }

    func bindUserData() {
        DispatchQueue.main.async {
            self.avatarView.user = self.user
            self.name.text = self.user?.name
            self.username.text = self.user?.username
            self.email.text = self.user?.emails.first?.email
        }
    }

    // MARK: Actions

    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        guard let user = user, let userId = user.identifier else { return }
        guard let name = name.text, let username = username.text, let email = email.text,
            !name.isEmpty, !username.isEmpty, !email.isEmpty else {
                Alert(key: "alert.update_profile_empty_fields").present()
                return
        }

        user.name = name
        user.username = username
        user.emails.first?.email = email

        var password: String?

        if let newPassword = newPassword.text, let passwordConfirmation = passwordConfirmation.text,
                !newPassword.isEmpty, !passwordConfirmation.isEmpty {
            if newPassword == passwordConfirmation {
                password = newPassword
            } else {
                // TODO: Alert about password confirmation not matching
            }
        }

        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        }

        let stopLoading = { [weak self] in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem = sender
            }
        }

        if let avatarFile = avatarFile {
            isUploadingAvatar = true

            let client = API.current()?.client(UploadClient.self)
            client?.uploadAvatar(data: avatarFile.data, filename: avatarFile.name, mimetype: avatarFile.type, completion: {
                self.isUploadingAvatar = false

                if !self.isUpdatingUser {
                    stopLoading()
                }

                self.avatarView.shouldRefreshCache = true
                self.avatarView.avatarPlaceholder = self.avatarView.imageView.image
                self.avatarView.updateAvatar()
            })
        }

        let stopUpdatingUser = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.isUpdatingUser = false
            if !weakSelf.isUploadingAvatar {
                stopLoading()
            }
        }

        isUpdatingUser = true
        let updateUserRequest = UpdateUserRequest(userId: userId, user: user, password: password)
        api?.fetch(updateUserRequest, succeeded: { result in
            stopUpdatingUser()
            if let errorMessage = result.errorMessage {
                Alert(key: "alert.update_profile_error").withMessage(errorMessage).present()
            }
        }, errored: { _ in
            stopUpdatingUser()
            Alert(key: "alert.update_profile_error").present()
        })
    }

    @IBAction func didPressAvatarButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: localized("chat.upload.take_photo"), style: .default, handler: { (_) in
                self.openCamera()
            }))
        }

        alert.addAction(UIAlertAction(title: localized("chat.upload.choose_from_library"), style: .default, handler: { (_) in
            self.openPhotosLibrary()
        }))

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 0 : 2
    }

}

extension EditProfileTableViewController: UINavigationControllerDelegate {}

extension EditProfileTableViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let filename = String.random()
        var file: FileUpload?

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }

            file = UploadHelper.file(
                for: imageData,
                name: "\(filename.components(separatedBy: ".").first ?? "image").jpeg",
                mimeType: "image/jpeg"
            )

            avatarView.imageView.image = image
        }

        avatarFile = file

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

extension EditProfileTableViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name: username.becomeFirstResponder()
        case username: email.becomeFirstResponder()
        case email: hideKeyboard()
        case newPassword: passwordConfirmation.becomeFirstResponder()
        case passwordConfirmation: hideKeyboard()
        default: break
        }

        return true
    }

}
