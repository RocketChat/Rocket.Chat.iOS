//
//  EmojiPicker.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

fileprivate typealias EmojiCategory = (name: String, emojis: [Emoji])

class EmojiPicker: UIView, RCEmojiKitLocalizable {
    static let defaults = UserDefaults(suiteName: "EmojiPicker")

    var customEmojis: [Emoji] = []
    var customCategory: (name: String, emojis: [Emoji]) {
        return (name: "custom", emojis: self.customEmojis)
    }

    var recentEmojis: [Emoji] {
        get {
            if let data = EmojiPicker.defaults?.value(forKey: "recentEmojis") as? Data {
                let emojis = try? PropertyListDecoder().decode(Array<Emoji>.self, from: data)
                return emojis ?? []
            }

            return []
        }

        set {
            let emojis = newValue.count < 31 ? newValue : Array(newValue.dropLast(newValue.count - 30))
            EmojiPicker.defaults?.set(try? PropertyListEncoder().encode(emojis), forKey: "recentEmojis")
        }
    }

    var recentCategory: (name: String, emojis: [Emoji]) {
        // remove invalid custom emojis
        let recentEmojis = self.recentEmojis.filter {
            guard case let .custom(imageUrl) = $0.type else { return true }
            return customEmojis.contains(where: { $0.imageUrl == imageUrl })
        }

        return (name: "recent", emojis: recentEmojis)
    }

    fileprivate let defaultCategories: [EmojiCategory] = [
        (name: "people", emojis: Emojione.people),
        (name: "nature", emojis: Emojione.nature),
        (name: "food", emojis: Emojione.food),
        (name: "activity", emojis: Emojione.activity),
        (name: "travel", emojis: Emojione.travel),
        (name: "objects", emojis: Emojione.objects),
        (name: "symbols", emojis: Emojione.symbols),
        (name: "flags", emojis: Emojione.flags)
    ]
    fileprivate var searchedCategories: [(name: String, emojis: [Emoji])] = []
    fileprivate func searchCategories(string: String) -> [EmojiCategory] {
        return ([customCategory] + defaultCategories).map {
            let emojis = $0.emojis.filter {
                $0.name.contains(string) || $0.shortname.contains(string) ||
                $0.keywords.joined(separator: " ").contains(string) ||
                $0.alternates.joined(separator: " ").contains(string)
            }

            return (name: $0.name, emojis: emojis)
        }.filter { !$0.emojis.isEmpty }
    }

    var isSearching: Bool {
        return searchBar?.text != nil && searchBar?.text?.isEmpty != true
    }

    fileprivate var currentCategories: [EmojiCategory] {
        if isSearching { return searchedCategories }

        let recent = (recentEmojis.count > 0 ? [recentCategory] : [])
        let custom = (customEmojis.count > 0 ? [customCategory] : [])

        return recent + custom + defaultCategories
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var categoriesView: UITabBar!

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = localized("searchbar.placeholder")
            searchBar.delegate = self
        }
    }

    @IBOutlet weak var emojisCollectionView: UICollectionView!

    let skinTones: [(name: String?, color: UIColor)] = [
        (name: nil, color: #colorLiteral(red: 0.999120295, green: 0.8114234805, blue: 0.06628075987, alpha: 1)),
        (name: "tone1", color: #colorLiteral(red: 0.982526958, green: 0.8808286786, blue: 0.7670835853, alpha: 1)),
        (name: "tone2", color: #colorLiteral(red: 0.8934452534, green: 0.7645885944, blue: 0.6247871518, alpha: 1)),
        (name: "tone3", color: #colorLiteral(red: 0.7776196599, green: 0.6034522057, blue: 0.4516467452, alpha: 1)),
        (name: "tone4", color: #colorLiteral(red: 0.6469842792, green: 0.4368215203, blue: 0.272474587, alpha: 1)),
        (name: "tone5", color: #colorLiteral(red: 0.391161263, green: 0.3079459369, blue: 0.2550256848, alpha: 1))
    ]

    var currentSkinToneIndex: Int {
        get {
            return EmojiPicker.defaults?.integer(forKey: "currentSkinToneIndex") ?? 0
        }

        set {
            EmojiPicker.defaults?.set(newValue, forKey: "currentSkinToneIndex")
        }
    }

    var currentSkinTone: (name: String?, color: UIColor) {
        return skinTones[currentSkinToneIndex]
    }

    @IBOutlet weak var skinToneButton: UIButton! {
        didSet {
            skinToneButton.layer.cornerRadius = skinToneButton.frame.width/2
            skinToneButton.backgroundColor = currentSkinTone.color
            skinToneButton.showsTouchWhenHighlighted = true
        }
    }

    @IBAction func didPressSkinToneButton(_ sender: UIButton) {
        currentSkinToneIndex += 1
        currentSkinToneIndex = currentSkinToneIndex % skinTones.count
        skinToneButton.backgroundColor = currentSkinTone.color
        emojisCollectionView.reloadData()
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
            layout.headerReferenceSize = CGSize(width: self.frame.width, height: 20)
        }

        emojisCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    private func setupCategoriesView() {
        let categoryItems = currentCategories.map { category -> UITabBarItem in
            let image = UIImage(named: category.name) ?? UIImage(named: "custom")
            let item = UITabBarItem(title: nil, image: image, selectedImage: image)
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            return item
        }

        categoriesView.setItems(categoryItems, animated: false)

        categoriesView.delegate = self
        categoriesView.layoutIfNeeded()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupCategoriesView()
        setupCollectionView()
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

        headerView.textLabel.text = localized("categories.\(currentCategories[indexPath.section].name)")

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCategories[section].emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }

        let emoji = currentCategories[indexPath.section].emojis[indexPath.row]

        if let file = emoji.imageUrl {
            cell.emojiView.emojiImageView.sd_setImage(with: URL(string: file), completed: nil)
        } else if emoji.supportsTones, let currentTone = currentSkinTone.name {
            let shortname = String(emoji.shortname.dropLast()) + "_\(currentTone):"
            let searchString = String(shortname.dropFirst().dropLast())
            cell.emojiView.emojiLabel.text = Emojione.values[searchString]
        } else {
            let searchString = String(emoji.shortname.dropFirst().dropLast())
            cell.emojiView.emojiLabel.text = Emojione.values[searchString]
        }

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

        let emoji = currentCategories[indexPath.section].emojis[indexPath.row]

        if emoji.supportsTones, let currentTone = currentSkinTone.name {
            let shortname = String(emoji.shortname.dropLast()) + "_\(currentTone):"
            emojiPicked?(shortname)
        } else {
            emojiPicked?(emoji.shortname)
        }

        if let index = recentEmojis.index(where: { $0.shortname == emoji.shortname  }) {
            recentEmojis.remove(at: index)
        }

        recentEmojis = [emoji] + recentEmojis
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 36.0)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let first = collectionView.indexPathsForVisibleItems.first {
            categoriesView.selectedItem = categoriesView.items?[first.section]
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
        emojisCollectionView.setContentOffset(emojisCollectionView.contentOffset.applying(CGAffineTransform(translationX: 0.0, y: -36.0)), animated: false)
    }
}

private class EmojiPickerSectionHeaderView: UICollectionReusableView {
    var textLabel: UILabel
    let screenWidth = UIScreen.main.bounds.width

    override init(frame: CGRect) {
        textLabel = UILabel()

        super.init(frame: frame)

        addSubview(textLabel)

        textLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
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
                               multiplier: 1.0, constant: 36.0)
        ])

        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
