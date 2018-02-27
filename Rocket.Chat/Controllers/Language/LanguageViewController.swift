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
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.setTitle(viewModel.resetLabel, for: .normal)
            resetButton.addTarget(self, action: #selector(resetLanguage), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
    }

    @objc private func resetLanguage() {
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        showMessage()
    }

    private func showMessage() {
        let alert = UIAlertController(title: nil, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension LanguageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellIdentifier, for: indexPath) as? ChangeLanguageCell else {
            fatalError("Could not dequeue reusable cell with identifier \(viewModel.cellIdentifier)")
        }

        cell.setLanguageName(for: viewModel.languages[indexPath.row])

        return cell
    }

}

extension LanguageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lang = viewModel.languages[indexPath.row]

        UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        showMessage()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
