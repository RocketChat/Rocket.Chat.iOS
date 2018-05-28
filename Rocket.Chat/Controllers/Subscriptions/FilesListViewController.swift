//
//  FilesListViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SimpleImageViewer
import MBProgressHUD
import MobilePlayer
import Nuke

class FilesListViewData {
    var subscription: Subscription?

    let pageSize = 20
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String = localized("chat.messages.files.list.title")

    var isFirstAppearing = true
    var isShowingAllFiles: Bool {
        return showing >= total
    }

    var cells: [File] = []

    func cell(at index: Int) -> File {
        return cells[cells.index(cells.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreFiles = false
    func loadMoreFiles(completion: (() -> Void)? = nil) {
        if isLoadingMoreFiles { return }

        if let subscription = subscription {
            isLoadingMoreFiles = true

            let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage*pageSize)]
            let filesRequest = RoomFilesRequest(roomId: subscription.rid, subscriptionType: subscription.type)
            API.current()?.fetch(filesRequest, options: options, completion: { [weak self] result in
                switch result {
                case .resource(let resource):
                    self?.handle(result: resource, completion: completion)
                default:
                    Alert.defaultError.present()
                }
            })
        }
    }

    private func handle(result: RoomFilesResource, completion: (() -> Void)? = nil) {
        self.showing += result.count ?? 0
        self.total = result.total ?? 0

        if let files = result.files {
            guard !files.isEmpty else {
                self.isLoadingMoreFiles = false
                completion?()
                return
            }

            self.cells.append(contentsOf: files)
        }

        self.currentPage += 1

        self.isLoadingMoreFiles = false
        completion?()
    }
}

class FilesListViewController: BaseViewController {
    var data = FilesListViewData()
    var documentController: UIDocumentInteractionController?

    @IBOutlet weak var tableView: UITableView!

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        let data = FilesListViewData()
        data.subscription = self.data.subscription
        data.loadMoreFiles {
            self.data = data
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.updateIsEmptyFile()
        }
    }

    func updateIsEmptyFile() {
        guard let label = tableView.backgroundView as? UILabel else { return }

        if data.cells.count == 0 {
            label.text = localized("chat.messages.files.list.empty")
        } else {
            label.text = ""
        }
    }

    func loadMoreFiles() {
        data.loadMoreFiles {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.updateIsEmptyFile()
        }
    }

    func openImage(fromFile file: File, fromImageView imageView: FLAnimatedImageView) {
        if imageView.animatedImage != nil || imageView.image != nil {
            let configuration = ImageViewerConfiguration { config in
                config.image = imageView.image
                config.animatedImage = imageView.animatedImage
                config.imageView = imageView
                config.allowSharing = true
            }
            present(ImageViewerController(configuration: configuration), animated: true)
        } else {
            openRemoteImage(fromFile: file, fromImageView: imageView)
        }
    }

    private func openRemoteImage(fromFile file: File, fromImageView imageView: FLAnimatedImageView?) {
        guard let fileURL = file.fullFileURL() else { return }

        let open: ((Image?) -> Void) = { [weak self] image in
            guard let strongSelf = self else { return }

            let configuration = ImageViewerConfiguration { config in
                if let image = image {
                    if file.isGif {
                        config.animatedImage = FLAnimatedImage(gifData: image.animatedImageData)
                    } else {
                        config.image = image
                    }
                }
                config.imageView = imageView
            }

            DispatchQueue.main.async {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                strongSelf.present(ImageViewerController(configuration: configuration), animated: false)
            }
        }

        MBProgressHUD.showAdded(to: view, animated: true)
        ImagePipeline.shared.loadImage(with: fileURL) { response, _ in
            open(response?.image)
        }
    }

    func openVideo(fromFile file: File) {
        guard let videoURL = file.fullFileURL() else { return }
        let controller = MobilePlayerViewController(contentURL: videoURL)
        controller.title = file.name
        controller.activityItems = [file.name, videoURL]
        present(controller, animated: true, completion: nil)
    }

    func openDocument(fromFile file: File) {
        guard let identifier = file.identifier else { return }
        guard let fileURL = file.fullFileURL() else { return }
        let localUniqueName = identifier + file.url.replacingOccurrences(of: "/", with: "")
        guard let filename = DownloadManager.filenameFor(localUniqueName) else { return }
        guard let localFileURL = DownloadManager.localFileURLFor(filename) else { return }

        // Open document itself
        func open() {
            documentController = UIDocumentInteractionController(url: localFileURL)
            documentController?.delegate = self

            DispatchQueue.main.async {
                self.documentController?.presentPreview(animated: true)
            }
        }

        // Checks if we do have the file in the system, before downloading it
        if DownloadManager.fileExists(localFileURL) {
            open()
        } else {
            let message = String(format: localized("chat.download.downloading_file"), file.name)
            let loadingHUD = MBProgressHUD.showAdded(to: view, animated: true)
            loadingHUD.label.text = message
            // Download file and cache it to be used later
            DownloadManager.download(url: fileURL, to: localFileURL) { [weak self] in
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    MBProgressHUD.hide(for: strongSelf.view, animated: true)
                    open()
                }
            }
        }
    }
}

// MARK: ViewController

extension FilesListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)

        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70

        let label = UILabel(frame: tableView.frame)
        label.textAlignment = .center
        label.textColor = .gray
        tableView.backgroundView = label

        registerCells()

        title = data.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if data.isFirstAppearing {
            data.isFirstAppearing = false
            loadMoreFiles()

            guard let refreshControl = tableView.refreshControl else { return }
            tableView.refreshControl?.beginRefreshing()
            tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        }
    }

    func registerCells() {
        tableView.register(UINib(
            nibName: String(describing: FileTableViewCell.self),
            bundle: Bundle.main
        ), forCellReuseIdentifier: FileTableViewCell.identifier)

        tableView.register(UINib(
            nibName: String(describing: LoaderTableViewCell.self),
            bundle: Bundle.main
        ), forCellReuseIdentifier: LoaderTableViewCell.identifier)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let audioViewController = segue.destination as? AudioFileViewController, let file = sender as? File {
            audioViewController.file = file
        }
    }
}

// MARK: UITableView

extension FilesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.cells.count + (data.isShowingAllFiles ? 0 : 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < data.cells.count else {
            loadMoreFiles()
            return tableView.dequeueReusableCell(withIdentifier: LoaderTableViewCell.identifier, for: indexPath)
        }

        let file = data.cell(at: indexPath.row)
        if let cell = tableView.dequeueReusableCell(withIdentifier: FileTableViewCell.identifier, for: indexPath) as? FileTableViewCell {
            cell.file = file
            return cell
        }

        return UITableViewCell()
    }

}

extension FilesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let fileCell = tableView.cellForRow(at: indexPath) as? FileTableViewCell else {
            return
        }

        let file = data.cell(at: indexPath.row)

        if file.isImage {
            openImage(fromFile: file, fromImageView: fileCell.filePreview)
            return
        }

        if file.isVideo {
            openVideo(fromFile: file)
            return
        }

        if file.isAudio {
            performSegue(withIdentifier: "showAudio", sender: file)
            return
        }

        if file.isDocument {
            openDocument(fromFile: file)
            return
        }
    }
}

// MARK: UIDocumentInteractionDelegate

extension FilesListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
