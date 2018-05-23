//
//  EditProfileTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

// swiftlint:disable file_length type_body_length
final class EditProfileTableViewController: UITableViewController, MediaPicker {

    static let identifier = String(describing: EditProfileTableViewController.self)

    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.text = viewModel.statusTitle
        }
    }

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

    let editingAvatarImage = UIImage(named: "Camera")?.imageWithTint(.RCEditingAvatarColor())

    var editButton: UIBarButtonItem?
    var saveButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?

    let api = API.current()
    var avatarFile: FileUpload?

    var authSettings: AuthSettings? {
        return AuthSettingsManager.shared.settings
    }

    var numberOfSections: Int {
        guard !isLoading else { return 0 }
        guard let authSettings = authSettings else { return 2 }
        return !authSettings.isAllowedToEditProfile || !authSettings.isAllowedToEditPassword ? 2 : 3
    }

    var canEditAnyInfo: Bool {
        guard
            authSettings?.isAllowedToEditProfile ?? false,
            authSettings?.isAllowedToEditAvatar ?? false ||
            authSettings?.isAllowedToEditName ?? false ||
            authSettings?.isAllowedToEditUsername ?? false ||
            authSettings?.isAllowedToEditEmail ?? false
        else {
            return false
        }

        return true
    }

    var isUpdatingUser = false
    var isUploadingAvatar = false
    var isLoading = true

    var currentPassword: String?
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
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressCancelEditingButton))
        navigationItem.title = viewModel.title

        disableUserInteraction()
        setupAvatarButton()
        fetchUserData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserStatus()
    }

    // MARK: Setup

    func setupAvatarButton() {
        avatarButton.addSubview(avatarView)
        avatarView.topAnchor.constraint(equalTo: avatarButton.topAnchor).isActive = true
        avatarView.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor).isActive = true
        avatarView.leadingAnchor.constraint(equalTo: avatarButton.leadingAnchor).isActive = true
        avatarView.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor).isActive = true

        if let imageView = avatarButton.imageView {
            avatarButton.bringSubview(toFront: imageView)
        }
    }

    func fetchUserData() {
        avatarButton.isHidden = true

        let fetchUserLoader = MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchUserLoader.mode = .indeterminate

        let stopLoading = {
            self.avatarButton.isHidden = false
            fetchUserLoader.hide(animated: true)
        }

        let meRequest = MeRequest()
        api?.fetch(meRequest) { [weak self] response in
            stopLoading()

            switch response {
            case .resource(let resource):
                if let errorMessage = resource.errorMessage {
                    Alert(key: "alert.load_profile_error").withMessage(errorMessage).present(handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    })
                } else {
                    self?.user = resource.user
                    self?.isLoading = false

                    if self?.canEditAnyInfo ?? false {
                        self?.navigationItem.rightBarButtonItem = self?.editButton
                    }

                    self?.tableView.reloadData()
                }
            case .error:
                Alert(key: "alert.load_profile_error").present(handler: { _ in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }

    func bindUserData() {
        avatarView.user = user
        name.text = user?.name
        username.text = user?.username
        email.text = user?.emails.first?.email

        updateUserStatus()
    }

    func updateUserStatus() {
        statusValueLabel.text = AuthManager.currentUser()?.status.rawValue.capitalized
    }

    // MARK: State Management

    @objc func beginEditing() {
        navigationItem.title = viewModel.editingTitle
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = cancelButton

        if authSettings?.isAllowedToEditAvatar ?? false {
            avatarButton.setImage(editingAvatarImage, for: .normal)
        }

        enableUserInteraction()
    }

    @objc func endEditing() {
        bindUserData()

        navigationItem.title = viewModel.title
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = editButton

        if authSettings?.isAllowedToEditAvatar ?? false {
            avatarButton.setImage(nil, for: .normal)
        }

        disableUserInteraction()
    }

    func enableUserInteraction() {
        avatarButton.isEnabled = authSettings?.isAllowedToEditAvatar ?? false

        if authSettings?.isAllowedToEditName ?? false {
            name.isEnabled = true
        } else {
            name.isEnabled = false
            name.textColor = .lightGray
        }

        if authSettings?.isAllowedToEditUsername ?? false {
            username.isEnabled = true
        } else {
            username.isEnabled = false
            username.textColor = .lightGray
        }

        if authSettings?.isAllowedToEditEmail ?? false {
            email.isEnabled = true
        } else {
            email.isEnabled = false
            email.textColor = .lightGray
        }

        if authSettings?.isAllowedToEditName ?? false {
            name.becomeFirstResponder()
        } else if authSettings?.isAllowedToEditUsername ?? false {
            username.becomeFirstResponder()
        } else if authSettings?.isAllowedToEditEmail ?? false {
            email.becomeFirstResponder()
        }
    }

    func disableUserInteraction() {
        hideKeyboard()
        avatarButton.isEnabled = false
        name.isEnabled = false
        name.textColor = .black
        username.isEnabled = false
        username.textColor = .black
        email.isEnabled = false
        email.textColor = .black
    }

    // MARK: Actions

    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        hideKeyboard()

        guard
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

        guard email.isValidEmail else {
            Alert(key: "alert.update_profile_invalid_email").present()
            return
        }

        var userRaw = JSON([:])

        if name != self.user?.name { userRaw["name"].string = name }
        if username != self.user?.username { userRaw["username"].string = username }
        if email != self.user?.emails.first?.email { userRaw["emails"] = [["address": email]] }

        let shouldUpdateUser = name != self.user?.name || username != self.user?.username || email != self.user?.emails.first?.email

        if !shouldUpdateUser {
            update(user: nil)
            return
        }

        let user = User()
        user.map(userRaw, realm: nil)

        if !(self.user?.emails.first?.email == email) {
            requestPasswordToUpdate(user: user)
        } else {
            update(user: user)
        }
    }

    fileprivate func requestPasswordToUpdate(user: User) {
        let alert = UIAlertController(
            title: localized("myaccount.settings.profile.password_required.title"),
            message: localized("myaccount.settings.profile.password_required.message"),
            preferredStyle: .alert
        )

        let updateUserAction = UIAlertAction(title: localized("myaccount.settings.profile.actions.save"), style: .default, handler: { _ in
            self.currentPassword = alert.textFields?.first?.text
            self.update(user: user)
        })

        updateUserAction.isEnabled = false

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = localized("myaccount.settings.profile.password_required.placeholder")
            if #available(iOS 11.0, *) {
                textField.textContentType = .password
            }
            textField.isSecureTextEntry = true

            _ = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { _ in
                updateUserAction.isEnabled = !(textField.text?.isEmpty ?? false)
            }
        })

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
        alert.addAction(updateUserAction)
        present(alert, animated: true)
    }

    /**
        This method will only update the avatar image
        of the user.
     */
    fileprivate func updateAvatar() {
        guard let avatarFile = avatarFile else { return }

        startLoading()
        isUploadingAvatar = true

        let client = API.current()?.client(UploadClient.self)
        client?.uploadAvatar(data: avatarFile.data, filename: avatarFile.name, mimetype: avatarFile.type, completion: { [weak self] in
            guard let strongSelf = self else { return }

            if !strongSelf.isUpdatingUser {
                strongSelf.alertSuccess(title: localized("alert.update_profile_success.title"))
            }

            strongSelf.isUploadingAvatar = false
            strongSelf.avatarView.avatarPlaceholder = UIImage(data: avatarFile.data)
            strongSelf.stopLoading()
            strongSelf.avatarFile = nil
        })
    }

    /**
        This method will only update the user information.
     */
    fileprivate func updateUserInformation(user: User) {
        isUpdatingUser = true

        if !isUploadingAvatar {
            startLoading()
        }

        let stopLoading: (_ shouldEndEditing: Bool) -> Void = { [weak self] shouldEndEditing in
            self?.isUpdatingUser = false
            self?.stopLoading(shouldEndEditing: shouldEndEditing)
        }

        let updateUserRequest = UpdateUserRequest(user: user, currentPassword: currentPassword)
        api?.fetch(updateUserRequest) { [weak self] response in
            guard let strongSelf = self else { return }

            switch response {
            case .resource(let resource):
                if let errorMessage = resource.errorMessage {
                    stopLoading(false)
                    Alert(key: "alert.update_profile_error").withMessage(errorMessage).present()
                    return
                }

                strongSelf.user = resource.user
                stopLoading(true)

                if !strongSelf.isUploadingAvatar {
                    strongSelf.alertSuccess(title: localized("alert.update_profile_success.title"))
                }
            case .error:
                stopLoading(false)
                Alert(key: "alert.update_profile_error").present()
            }
        }
    }

    /**
        This method will check if there's an new avatar
        to be updated and if there's any information on the
        user to be updated as well. They're both different API
        calls that need to be made.
     */
    fileprivate func update(user: User?) {
        if avatarFile != nil {
            updateAvatar()
        }

        guard let user = user else {
            if !isUploadingAvatar {
                endEditing()
            }

            return
        }

        updateUserInformation(user: user)
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

    @objc func didPressCancelEditingButton() {
        avatarView.avatarPlaceholder = nil
        avatarView.imageView.image = nil
        endEditing()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func startLoading() {
        view.isUserInteractionEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }

    func stopLoading(shouldEndEditing: Bool = true, shouldRefreshAvatar: Bool = false) {
        if !isUpdatingUser, !isUploadingAvatar {
            view.isUserInteractionEnabled = true
            navigationItem.leftBarButtonItem?.isEnabled = true

            if shouldEndEditing {
                endEditing()
            } else {
                navigationItem.rightBarButtonItem = saveButton
            }
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPassword = segue.destination as? NewPasswordTableViewController {
            newPassword.passwordUpdated = { [weak self] newPasswordViewController in
                newPasswordViewController?.navigationController?.popViewControler(animated: true, completion: {
                    self?.alertSuccess(title: localized("alert.update_password_success.title"))
                })
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return viewModel.profileSectionTitle
        default: return ""
        }
    }

}

extension EditProfileTableViewController: UINavigationControllerDelegate {}

extension EditProfileTableViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let filename = String.random()
        var file: FileUpload?

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { return }

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
