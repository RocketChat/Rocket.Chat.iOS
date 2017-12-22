//
//  EmojiPicker.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class EmojiPicker: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var categoriesView: UITabBar! {
        didSet {
            let items = Emojione.categories.keys.map { category -> UITabBarItem in
                let item = UITabBarItem(title: nil, image: UIImage(named: category) ?? UIImage(named: "custom"), selectedImage: nil)
                item.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
                return item
            }
            categoriesView.setItems(items, animated: true)
            categoriesView.delegate = self
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {

        }
    }

    @IBOutlet weak var emojisCollectionView: UICollectionView! {
        didSet {
            setupCollectionView()
        }
    }

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

        let emojiCellNib = UINib(nibName: "EmojiCollectionViewCell", bundle: nil)
        emojisCollectionView.register(emojiCellNib, forCellWithReuseIdentifier: "EmojiCollectionViewCell")

        emojisCollectionView.register(EmojiPickerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "EmojiPickerSectionHeaderView")

        (emojisCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
    }
}

extension EmojiPicker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Emojione.categories.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "EmojiPickerSectionHeaderView",
            for: indexPath
        ) as? EmojiPickerSectionHeaderView else { return UICollectionReusableView() }

        headerView.textLabel.text = Array(Emojione.categories.keys)[indexPath.section]

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = Array(Emojione.categories.keys)[section]
        return Emojione.categories[key]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }

        let key = Array(Emojione.categories.keys)[indexPath.section]
        cell.emojiView.emojiLabel.text = Emojione.transform(string: Emojione.categories[key]?[indexPath.row] ?? "NO")

        return cell
    }
}

extension EmojiPicker: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else { return }
        emojisCollectionView.scrollToItem(at: IndexPath(row: 0, section: index), at: .centeredVertically, animated: true)
    }
}

private class EmojiPickerSectionHeaderView: UICollectionReusableView {
    var textLabel: UILabel
    let screenWidth = UIScreen.main.bounds.width

    override init(frame: CGRect) {
        textLabel = UILabel()

        super.init(frame: frame)

        addSubview(textLabel)

        textLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 16)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal,
                               toItem: self, attribute: .leadingMargin,
                               multiplier: 1.0, constant: 0.0),

            NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal,
                               toItem: self, attribute: .trailingMargin,
                               multiplier: 1.0, constant: 0.0)
        ])

        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
