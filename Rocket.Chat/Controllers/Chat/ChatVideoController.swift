//
//  ChatVideoController.swift
//  Rocket.Chat
//
//  Created by Dylan Robson on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import VGPlayer
import SnapKit

class ChatVideoController: UIViewController {
    var player: VGPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let player = self.player else { return }
        view.addSubview(player.displayView)
        self.player.backgroundMode = .suspend
        self.player.play()
        self.player.delegate = self
        self.player.displayView.delegate = self
        self.player.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.edges.equalTo(strongSelf.view)
        }
        let shareButton: UIButton = UIButton(type: .custom)
        shareButton.setTitle("Share", for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        self.player.displayView.topView.addSubview(shareButton)
        shareButton.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            let topView = strongSelf.player.displayView.topView
            make.right.equalTo(topView).offset(-10)
            make.top.equalTo(topView).offset(28)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @objc func shareButtonTapped() {
        guard let url = player.contentURL else { return }
        guard let title = player.displayView.titleLabel.text else { return }
        let vc = UIActivityViewController(activityItems: [title, url], applicationActivities: [])
        present(vc, animated: true)
    }
}

extension ChatVideoController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        print("Player Error:", error)
    }
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        print("Player State:", state)
    }
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        print("Buffer State:", state)
    }
}

extension ChatVideoController: VGPlayerViewDelegate {
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
    }
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        dismiss(animated: true)
    }
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
    }
}
