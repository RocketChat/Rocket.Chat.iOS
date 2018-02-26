//
//  DrawingViewController.swift
//  Rocket.Chat
//
//  Created by Anirudh Vajjala on 22/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//
import SSSlider
import UIKit
import Photos
import MobileCoreServices
import RealmSwift
import SlackTextViewController
import SimpleImageViewer
class DrawingViewController: UIViewController, colorDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorPickerView: ColorPicker!
    @IBOutlet weak var editimg: UIImageView!
    @IBOutlet weak var swapTool: UIButton!
    @IBOutlet weak var brushsize: SSSlider!
    @IBOutlet weak var opacity: SSSlider!
    var selectedImage: UIImage!
    var color: UIColor!
    var lastColor: UIColor!
    var tool: UIImageView!
    var isdrawing = true
    var lastPoint = CGPoint.zero
    var brushSize: CGFloat = 5.0
    var swiped = false
    @IBAction func swapToolClicked(_ sender: Any) {
        self.swapToolClicked1()
    }
    @IBAction func resetClicked(_ sender: Any) {
        self.resetClicked1()
    }
    @IBAction func shareDrawingClicked(_ sender: Any) {
        self.shareDrawingClicked1()
    }
    @IBAction func saveClicked(_ sender: Any) {
        self.saveClicked1()
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.delegate = self
        color = UIColor(red: 0/255, green: 167/255, blue: 255/255, alpha: 1.0)
    }
    func pickedColor(color: UIColor) {
        self.color = color
        editimg.backgroundColor = color
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override open var shouldAutorotate: Bool {
        return false
    }
}

