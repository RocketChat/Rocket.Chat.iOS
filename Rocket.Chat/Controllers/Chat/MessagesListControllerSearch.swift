//
//  MessagesListControllerSearch.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 25/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

// MARK: UISearchBarDelegate

extension MessagesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            data.cellsPages = []
            collectionView.reloadData()
            updateIsEmptyMessage()
            return
        }

        self.data.isLoadingSearchResults = true
        self.collectionView.reloadData()
        self.updateIsEmptyMessage()

        searchTimer?.invalidate()
        searchTimer = Timer(timeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.searchMessages(withText: searchText)
        })

        if let timer = searchTimer {
            RunLoop.main.add(timer, forMode: .commonModes)
        }
    }
}
