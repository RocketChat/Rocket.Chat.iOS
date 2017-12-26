//
//  EmojiPicker.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class EmojiPicker: UIView {
    let emojisByCategories = Emojione.categories.filter({ key, _ in key != "modifier" && key != "regional"})

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var categoriesView: UITabBar! {
        didSet {
            let categoryItems = emojisByCategories.keys.map { category -> UITabBarItem in
                let item = UITabBarItem(title: nil, image: UIImage(named: category) ?? UIImage(named: "custom"), selectedImage: nil)
                item.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
                return item
            }

            categoriesView.setItems(categoryItems, animated: false)
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

        (emojisCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
    }
}

extension EmojiPicker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojisByCategories.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "EmojiPickerSectionHeaderView",
            for: indexPath
        ) as? EmojiPickerSectionHeaderView else { return UICollectionReusableView() }

        headerView.textLabel.text = Array(emojisByCategories.keys)[indexPath.section]

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = Array(emojisByCategories.keys)[section]
        return emojisByCategories[key]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }

        let key = Array(emojisByCategories.keys)[indexPath.section]
        cell.emojiView.emojiLabel.text = Emojione.transform(string: emojisByCategories[key]?[indexPath.row].shortname ?? "NO")

        return cell
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
        guard
            let category = emojisByCategories[Array(emojisByCategories.keys)[indexPath.section]]
        else {
            return
        }

        emojiPicked?(category[indexPath.row].shortname)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 28.0)
    }
}

extension EmojiPicker: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else { return }

        let indexPath = IndexPath(row: 1, section: index)
        if let attributes = emojisCollectionView.layoutAttributesForSupplementaryElement(
            ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
            let topOfHeader = CGPoint(x: 0, y: attributes.frame.origin.y - emojisCollectionView.contentInset.top)
            emojisCollectionView.setContentOffset(topOfHeader, animated: true)
        }
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
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal,
                               toItem: self, attribute: .leadingMargin,
                               multiplier: 1.0, constant: 0.0),

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
