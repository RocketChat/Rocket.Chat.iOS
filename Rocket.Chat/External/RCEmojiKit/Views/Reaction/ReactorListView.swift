//
//  ReactorListView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 2/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

// MARK: Reactor Cell

protocol ReactorPresenter {
    var reactor: String { get set }
}

typealias ReactorCell = UITableViewCell & ReactorPresenter

class DefaultReactorCell: UITableViewCell, ReactorPresenter {
    var reactor: String = "" {
        didSet {
            textLabel?.text = reactor
        }
    }

    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
    }

    override func awakeFromNib() {
        textLabel?.font = UIFont.systemFont(ofSize: 11.0)
    }
}

// MARK: Reactor List

struct ReactorListViewModel: RCEmojiKitLocalizable {
    let reactionViewModels: [ReactionViewModel]

    func titleForHeaderInSection(_ section: Int) -> String {
        let reactionViewModel = reactionViewModels[section]

        if reactionViewModel.reactors.count > 1 {
            return String(
                format: localized("reactorlist.header.title.multiple"),
                reactionViewModels[section].count,
                reactionViewModels[section].emoji
            )
        } else {
            return String(
                format: localized("reactorlist.header.title.single"),
                reactionViewModels[section].emoji
            )
        }
    }

    init(reactionViewModels: [ReactionViewModel]) {
        self.reactionViewModels = reactionViewModels.sorted { $0.emoji > $1.emoji }
    }

    static var emptyState: ReactorListViewModel {
        return ReactorListViewModel(reactionViewModels: [])
    }
}

class ReactorListView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var reactorTableView: UITableView! {
        didSet {
            reactorTableView.dataSource = self
            reactorTableView.delegate = self
        }
    }

    var closePressed: () -> Void = { }

    var model: ReactorListViewModel = .emptyState {
        didSet {
            map(model)
        }
    }

    func map(_ model: ReactorListViewModel) {

    }

    func registerReactorNib(_ nib: UINib) {
        reactorTableView.register(nib, forCellReuseIdentifier: "ReactorCell")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    @IBAction func closePressed(_ sender: UIBarButtonItem) {
        closePressed()
    }
}

// MARK: Initialization

extension ReactorListView {
    private func commonInit() {
        Bundle.main.loadNibNamed("ReactorListView", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

// MARK: UITableViewDataSource

extension ReactorListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "ReactorCell")
        var cell = dequeuedCell as? ReactorCell ?? DefaultReactorCell()

        cell.reactor = model.reactionViewModels[indexPath.section].reactors[indexPath.row]

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return model.reactionViewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.reactionViewModels[section].reactors.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.titleForHeaderInSection(section)
    }
}

// MARK: UITableViewDelegate

extension ReactorListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)

        let stackView = UIStackView(frame: CGRect(x: 8, y: 8, width: tableView.frame.size.width - 8, height: 24))
        stackView.spacing = 8

        let reactionView = ReactionView()
        reactionView.model = model.reactionViewModels[section]

        let label = UILabel(frame: CGRect(x: 60, y: 0, width: tableView.frame.size.width - 60, height: 40))
        label.textAlignment = .left
        label.text = reactionView.model.emoji

        stackView.addArrangedSubview(reactionView)
        stackView.addArrangedSubview(label)

        view.addSubview(stackView)

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
