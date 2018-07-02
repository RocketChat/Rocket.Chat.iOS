//
//  ThemePreferenceController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ThemePreferenceController: BaseTableViewController {

    let viewModel = ThemePreferenceViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
    }
}

extension ThemePreferenceController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ThemePreferenceCell.identifier, for: indexPath) as? ThemePreferenceCell else {
            return UITableViewCell()
        }
        cell.cellTheme = viewModel.themes[indexPath.row].theme
        cell.titleLabel.text = viewModel.themes[indexPath.row].title
        cell.baseColorView.backgroundColor = viewModel.themes[indexPath.row].theme.backgroundColor
        cell.auxiliaryColorView.backgroundColor = viewModel.themes[indexPath.row].theme.bodyText

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.footer
    }
}

extension ThemePreferenceController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTheme = viewModel.themes[indexPath.row].theme
        if ThemeManager.theme != selectedTheme {
            ThemeManager.theme = selectedTheme
        }

        tableView.deselectRow(at: indexPath, animated: true)

        guard let titleForEvent = ThemeManager.themes.filter({ $0.theme == selectedTheme }).first?.title else {
            return
        }

        AnalyticsManager.log(event: .updatedTheme(theme: titleForEvent))
    }
}
