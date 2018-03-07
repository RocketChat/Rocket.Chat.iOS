//
//  EditProfileTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

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

    @IBOutlet weak var newPassword: UITextField! {
        didSet {
            newPassword.placeholder = viewModel.passwordPlaceholder
        }
    }

    @IBOutlet weak var passwordConfirmation: UITextField! {
        didSet {
            passwordConfirmation.placeholder = viewModel.passwordConfirmationPlaceholder
        }
    }

    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.title = viewModel.saveButtonTitle
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

    var backButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?

    let api = API.current()
    var isUpdatingUser = false
    var isUploadingAvatar = false {
        didSet {
            hasUnsavedNewAvatar = !isUploadingAvatar ? false : hasUnsavedNewAvatar
        }
    }
    var isLoading = true
    var avatarFile: FileUpload?

    var user: User? = User() {
        didSet {
            bindUserData()
        }
    }

    var hasUnsavedNewAvatar = false
    var hasUnsavedChanges: Bool {
        let passwordInput = validatePasswordInput(shouldAlertUser: false)

        guard
            !hasUnsavedNewAvatar,
            user?.name == name.text,
            user?.username == username.text,
            user?.emails.first?.email == email.text,
            passwordInput.password == nil && !passwordInput.invalidInput
        else {
            return true
        }

        return false
    }

    private let viewModel = EditProfileViewModel()

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(hideKeyboard))
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.title = viewModel.title

        setupAvatarButton()
        fetchUserData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParentViewController && hasUnsavedChanges {
            Alert(key: "alert.discarding_changes").present()
        }
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
        avatarView.removeCacheForCurrentURL()

        let meRequest = MeRequest()
        api?.fetch(meRequest, succeeded: { (result) in
            if let errorMessage = result.errorMessage {
                Alert(key: "alert.load_profile_error").withMessage(errorMessage).present(handler: { _ in
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
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = cancelButton
        return
//        hideKeyboard()

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

        let passwordInput = validatePasswordInput()
        if passwordInput.invalidInput {
            return
        }

        startLoading()

        if let avatarFile = avatarFile {
            isUploadingAvatar = true

            let client = API.current()?.client(UploadClient.self)
            client?.uploadAvatar(data: avatarFile.data, filename: avatarFile.name, mimetype: avatarFile.type, completion: { [weak self] in
                self?.isUploadingAvatar = false
                self?.stopLoading(sender: sender)
                self?.avatarView.avatarPlaceholder = self?.avatarView.imageView.image
                self?.avatarView.removeCacheForCurrentURL(forceUpdate: true)
            })
        }

        let stopLoading = { [weak self] in
            self?.isUpdatingUser = false
            self?.stopLoading(sender: sender)
        }

        isUpdatingUser = true

        let updateUserRequest = UpdateUserRequest(userId: userId, user: user, password: passwordInput.password)
        api?.fetch(updateUserRequest, succeeded: { result in
            stopLoading()
            if let errorMessage = result.errorMessage {
                Alert(key: "alert.update_profile_error").withMessage(errorMessage).present()
            }
        }, errored: { _ in
            stopLoading()
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

    @objc func hideKeyboard() {
        navigationItem.hidesBackButton = false
        var items = navigationItem.leftBarButtonItems
        items?.remove(object: cancelButton!)
        navigationItem.setLeftBarButtonItems(items, animated: true)
//        view.endEditing(true)
    }

    func validatePasswordInput(shouldAlertUser: Bool = true) -> (password: String?, invalidInput: Bool) {
        if newPassword.text != nil, !(newPassword.text?.isEmpty ?? true) {
            if passwordConfirmation.text == nil || (passwordConfirmation.text?.isEmpty ?? true) {
                newPassword.text = nil
                if shouldAlertUser { Alert(key: "alert.missing_password_field_error").present() }
                return (nil, true)
            }
        }

        if passwordConfirmation.text != nil, !(passwordConfirmation.text?.isEmpty ?? true) {
            if newPassword.text == nil || (newPassword.text?.isEmpty ?? false) {
                passwordConfirmation.text = nil
                if shouldAlertUser { Alert(key: "alert.missing_password_field_error").present() }
                return (nil, true)
            }
        }

        guard
            let newPassword = newPassword.text,
            let passwordConfirmation = passwordConfirmation.text,
            !newPassword.isEmpty,
            !passwordConfirmation.isEmpty
        else {
            return (nil, false)
        }

        if newPassword == passwordConfirmation {
            return (newPassword, false)
        } else {
            self.newPassword.text = nil
            self.passwordConfirmation.text = nil
            if shouldAlertUser { Alert(key: "alert.password_mismatch_error").present() }
            return (nil, true)
        }
    }

    func startLoading() {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        }
    }

    func stopLoading(sender: UIBarButtonItem) {
        if !isUpdatingUser, !isUploadingAvatar {
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.rightBarButtonItem = sender
            }
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
        case 1:
            return viewModel.passwordSectionTitle
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

        hasUnsavedNewAvatar = true
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
