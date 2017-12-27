//
//  EmojiPicker.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

fileprivate typealias EmojiCategory = (name: String, emojis: [Emoji])

class EmojiPicker: UIView {
    fileprivate let categories: [EmojiCategory] = [
        (name: "activity", emojis: Emojione.activity),
        (name: "people", emojis: Emojione.people),
        (name: "travel", emojis: Emojione.travel),
        (name: "nature", emojis: Emojione.nature),
        (name: "objects", emojis: Emojione.objects),
        (name: "symbols", emojis: Emojione.symbols),
        (name: "food", emojis: Emojione.food),
        (name: "flags", emojis: Emojione.flags)
    ]
    fileprivate var searchedCategories: [(name: String, emojis: [Emoji])] = []
    fileprivate func searchCategories(string: String) -> [EmojiCategory] {
        return categories.map {
            let emojis = $0.emojis.filter {
                $0.name.contains(string) || $0.shortname.contains(string) ||
                $0.keywords.joined(separator: " ").contains(string) ||
                $0.alternates.joined(separator: " ").contains(string)
            }

            return (name: $0.name, emojis: emojis)
        }.filter { !$0.emojis.isEmpty }
    }

    var isSearching: Bool {
        return searchBar.text != nil && searchBar.text?.isEmpty != true
    }

    fileprivate var currentCategories: [EmojiCategory] {
        return isSearching ? searchedCategories : categories
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var categoriesView: UITabBar! {
        didSet {
            let categoryItems = categories.map { category -> UITabBarItem in
                let item = UITabBarItem(title: nil, image: UIImage(named: category.name) ?? UIImage(named: "custom"), selectedImage: nil)
                item.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
                return item
            }

            categoriesView.setItems(categoryItems, animated: false)
            categoriesView.delegate = self
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }

    @IBOutlet weak var emojisCollectionView: UICollectionView! {
        didSet {
            setupCollectionView()
        }
    }

    var emojiPicked: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("EmojiPicker", owner: self, options: nil)

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": contentView]
            )
        )
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": contentView]
            )
        )
    }

    private func setupCollectionView() {
        emojisCollectionView.dataSource = self
        emojisCollectionView.delegate = self

        let emojiCellNib = UINib(nibName: "EmojiCollectionViewCell", bundle: nil)
        emojisCollectionView.register(emojiCellNib, forCellWithReuseIdentifier: "EmojiCollectionViewCell")
        emojisCollectionView.register(EmojiPickerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EmojiPickerSectionHeaderView")

        if let layout = emojisCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.headerReferenceSize = CGSize(width: self.frame.width, height: 26.0)
        }

        emojisCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
    }
}

extension EmojiPicker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "EmojiPickerSectionHeaderView",
            for: indexPath
        ) as? EmojiPickerSectionHeaderView else { return UICollectionReusableView() }

        headerView.textLabel.text = currentCategories[indexPath.section].name

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCategories[section].emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }

        let emoji = currentCategories[indexPath.section].emojis[indexPath.row]
        cell.emojiView.emojiLabel.text = Emojione.transform(string: emoji.shortname)

        return cell
    }
}

extension EmojiPicker: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCategories = searchCategories(string: searchText.lowercased())
        emojisCollectionView.reloadData()
    }
}

extension EmojiPicker: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 36.0, height: 36.0)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        emojiPicked?(currentCategories[indexPath.section].emojis[indexPath.row].shortname)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 28.0)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let item = categoriesView.items?[indexPath.section] {
            categoriesView.selectedItem = item
        }
    }
}

extension EmojiPicker: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else { return }

        searchBar.resignFirstResponder()
        searchBar.text = ""

        emojisCollectionView.reloadData()
        emojisCollectionView.layoutIfNeeded()

        let indexPath = IndexPath(row: 1, section: index)
        emojisCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        emojisCollectionView.setContentOffset(emojisCollectionView.contentOffset.applying(CGAffineTransform(translationX: 0.0, y: -28.0)), animated: false)
    }
}

private class EmojiPickerSectionHeaderView: UICollectionReusableView {
    var textLabel: UILabel
    let screenWidth = UIScreen.main.bounds.width

    override init(frame: CGRect) {
        textLabel = UILabel()

        super.init(frame: frame)

        addSubview(textLabel)

        textLabel.font = .systemFont(ofSize: UIFont.systemFontSize + 10)
        textLabel.textColor = .gray
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal,
                               toItem: self, attribute: .leadingMargin,
                               multiplier: 1.0, constant: -8.0),

            NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal,
                               toItem: self, attribute: .trailingMargin,
                               multiplier: 1.0, constant: 0.0),

            NSLayoutConstraint(item: textLabel, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .height,
                               multiplier: 1.0, constant: 26.0)
        ])

        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
