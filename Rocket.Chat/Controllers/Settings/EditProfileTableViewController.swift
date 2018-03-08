//
//  EditProfileTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import MBProgressHUD

class EditProfileTableViewController: UITableViewController, MediaPicker {

    @IBOutlet weak var name: UITextField! {
        didSet {
            name.placeholder = viewModel.namePlaceholder
        }
    }

    @IBOutlet weak var username: UITextField! {
        didSet {
            username.placeholder = viewModel.usernamePlaceholder
        }
    }

    @IBOutlet weak var email: UITextField! {
        didSet {
            email.placeholder = viewModel.emailPlaceholder
        }
    }

    @IBOutlet weak var changeYourPassword: UILabel! {
        didSet {
            changeYourPassword.text = viewModel.changeYourPasswordTitle
        }
    }

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

    var editButton: UIBarButtonItem?
    var saveButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?

    let api = API.current()
    var avatarFile: FileUpload?

    var isUpdatingUser = false
    var isUploadingAvatar = false
    var isLoading = true
    var isEditingProfile = false

    var user: User? = User() {
        didSet {
            bindUserData()
        }
    }

    private let viewModel = EditProfileViewModel()

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)

        editButton = UIBarButtonItem(title: viewModel.editButtonTitle, style: .plain, target: self, action: #selector(beginEditing))
        saveButton = UIBarButtonItem(title: viewModel.saveButtonTitle, style: .done, target: self, action: #selector(saveProfile(_:)))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(endEditing(shouldKeepUnsavedChanges:)))
        navigationItem.title = viewModel.title

        disableUserInteraction()
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
        avatarButton.isHidden = true
        avatarView.removeCacheForCurrentURL()

        var fetchUserLoader: MBProgressHUD!

        DispatchQueue.main.async {
            fetchUserLoader = MBProgressHUD.showAdded(to: self.view, animated: true)
            fetchUserLoader.mode = .indeterminate
        }

        let stopLoading = {
            DispatchQueue.main.async {
                self.avatarButton.isHidden = false
                fetchUserLoader.hide(animated: true)
            }
        }

        let meRequest = MeRequest()
        api?.fetch(meRequest, succeeded: { [weak self] result in
            stopLoading()
            if let errorMessage = result.errorMessage {
                Alert(key: "alert.load_profile_error").withMessage(errorMessage).present(handler: { _ in
                    self?.navigationController?.popViewController(animated: true)
                })
            } else {
                self?.user = result.user
                self?.isLoading = false
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem = self?.editButton
                    self?.tableView.reloadData()
                }
            }
        }, errored: { _ in
            stopLoading()
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

    // MARK: State Management

    @objc func beginEditing() {
        isEditingProfile = true
        navigationItem.title = viewModel.editingTitle
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = cancelButton
        enableUserInteraction()
    }

    @objc func endEditing(shouldKeepUnsavedChanges: Bool = false) {
        if !shouldKeepUnsavedChanges {
            bindUserData()
        }

        isEditingProfile = false
        navigationItem.title = viewModel.title
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = editButton
        disableUserInteraction()
    }

    func enableUserInteraction() {
        avatarButton.isEnabled = true
        name.isEnabled = true
        username.isEnabled = true
        email.isEnabled = true
        name.becomeFirstResponder()
    }

    func disableUserInteraction() {
        hideKeyboard()
        avatarButton.isEnabled = false
        name.isEnabled = false
        username.isEnabled = false
        email.isEnabled = false
    }

    // MARK: Actions

    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        hideKeyboard()

        guard
            let user = user,
            let userId = user.identifier,
            let name = name.text,
            let username = username.text,
            let email = email.text,
            !name.isEmpty,
            !username.isEmpty,
            !email.isEmpty
        else {
            Alert(key: "alert.update_profile_empty_fields").present()
            return
        }

        user.name = name
        user.username = username
        user.emails.first?.email = email

        startLoading()

        if let avatarFile = avatarFile {
            isUploadingAvatar = true

            let client = API.current()?.client(UploadClient.self)
            client?.uploadAvatar(data: avatarFile.data, filename: avatarFile.name, mimetype: avatarFile.type, completion: { [weak self] in
                guard let weakSelf = self else { return }
                if !weakSelf.isUpdatingUser { weakSelf.alertSuccess(title: localized("alert.update_profile_success.title")) }
                weakSelf.isUploadingAvatar = false
                weakSelf.stopLoading()
                weakSelf.avatarView.avatarPlaceholder = self?.avatarView.imageView.image
                weakSelf.avatarView.removeCacheForCurrentURL(forceUpdate: true)
            })
        }

        let stopLoading = { [weak self] in
            self?.isUpdatingUser = false
            self?.stopLoading()
        }

        isUpdatingUser = true

        let updateUserRequest = UpdateUserRequest(userId: userId, user: user)
        api?.fetch(updateUserRequest, succeeded: { [weak self] result in
            guard let weakSelf = self else { return }
            stopLoading()
            if !weakSelf.isUploadingAvatar { weakSelf.alertSuccess(title: localized("alert.update_profile_success.title")) }
            if let errorMessage = result.errorMessage {
                Alert(key: "alert.update_profile_error").withMessage(errorMessage).present()
            }
        }, errored: { _ in
            stopLoading()
            Alert(key: "alert.update_profile_error").present()
        })
    }

    @IBAction func didPressAvatarButton(_ sender: UIButton) {
        hideKeyboard()
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

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func startLoading() {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        }
    }

    func stopLoading() {
        if !isUpdatingUser, !isUploadingAvatar {
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.endEditing(shouldKeepUnsavedChanges: true)
            }
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPassword = segue.destination as? NewPasswordTableViewController {
            newPassword.user = user
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 0 : 2
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return viewModel.profileSectionTitle
        default:
            return ""
        }
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
        default: break
        }

        return true
    }

}
