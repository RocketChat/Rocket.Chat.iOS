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

final class DefaultReactorCell: UITableViewCell, ReactorPresenter {
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

    static var emptyState: ReactorListViewModel {
        return ReactorListViewModel(reactionViewModels: [])
    }
}

final class ReactorListView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var reactorTableView: UITableView! {
        didSet {
            reactorTableView.bounces = false
            reactorTableView.tableFooterView = UIView()

            reactorTableView.dataSource = self
            reactorTableView.delegate = self
        }
    }

    var closePressed: () -> Void = { }
    var selectedReactor: (String, CGRect) -> Void = { _, _ in }
    var configureCell: (ReactorCell) -> Void = { _ in }

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

        configureCell(cell)

        cell.reactor = model.reactionViewModels[indexPath.section].reactors[indexPath.row]

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return model.reactionViewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.reactionViewModels[section].reactors.count
    }
}

// MARK: UITableViewDelegate

extension ReactorListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)

        let stackView = UIStackView(frame: CGRect(x: 16, y: 8, width: tableView.frame.size.width - 16, height: 24))
        stackView.spacing = 8

        let reactionView = ReactionView()
        reactionView.model = model.reactionViewModels[section]

        let label = UILabel()
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rect = tableView.rectForRow(at: indexPath)
        selectedReactor(model.reactionViewModels[indexPath.section].reactors[indexPath.row], rect)
    }
}
