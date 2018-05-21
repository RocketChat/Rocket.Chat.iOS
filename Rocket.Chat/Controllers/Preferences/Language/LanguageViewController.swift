//
//  LanguageViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 26.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class LanguageViewController: UIViewController {
    private let viewModel = LanguageViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
    }

    private func showMessage() {
        let alert = UIAlertController(title: nil, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension LanguageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? viewModel.languages.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.resetCellIdentifier, for: indexPath) as? ChangeLanguageResetCell else {
                fatalError("Could not dequeue reusable cell with identifier \(viewModel.cellIdentifier)")
            }

            cell.resetLabel.text = viewModel.resetLabel

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellIdentifier, for: indexPath) as? ChangeLanguageCell else {
            fatalError("Could not dequeue reusable cell with identifier \(viewModel.cellIdentifier)")
        }

        let lang = viewModel.languages[indexPath.row]
        cell.setLanguageName(for: lang)

        if lang == Locale.preferredLanguages[0] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

}

extension LanguageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let lang = viewModel.languages[indexPath.row]
            AppManager.language = lang
        } else {
            AppManager.resetLanguage()
            showMessage()
        }

        showMessage()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
