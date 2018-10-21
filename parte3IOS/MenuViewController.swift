//
//  MenuViewController.swift
//  parte3IOS
//
//  Created by Laura Corssac on 21/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

enum MenuOption {
    case contrast, negative, brightness, original, flipVertical, flipHorizontal, grayScale, startRecording, stopRecording, sobel, canny, gaussianBlur, rotate, scale
}
protocol ControlVCDelegate: class {
    func didSelect(option: MenuOption)
}

class MenuViewController: UIViewController {
    
    weak var delegate: ControlVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func negative(_ sender: Any) {
        delegate?.didSelect(option: .negative)
    }
    @IBAction func flipHor(_ sender: UIButton) {
        delegate?.didSelect(option: .flipHorizontal)
    }
    @IBAction func flipVer(_ sender: Any) {
        delegate?.didSelect(option: .flipVertical)
    }
    @IBAction func contrast(_ sender: Any) {
        delegate?.didSelect(option: .contrast)
    }
    @IBAction func brightness(_ sender: Any) {
        delegate?.didSelect(option: .brightness)
    }
    @IBAction func grayScale(_ sender: Any) {
        delegate?.didSelect(option: .grayScale)
    }
    @IBAction func gaussianBlur(_ sender: Any) {
        delegate?.didSelect(option: .gaussianBlur)
    }
    @IBAction func sobel(_ sender: Any) {
        delegate?.didSelect(option: .sobel)
    }
    @IBAction func canny(_ sender: Any) {
        delegate?.didSelect(option: .canny)
    }
    @IBAction func start(_ sender: Any) {
        delegate?.didSelect(option: .startRecording)
    }
    @IBAction func stop(_ sender: Any) {
        delegate?.didSelect(option: .stopRecording)
    }
    @IBAction func scale(_ sender: Any) {
        delegate?.didSelect(option: .scale)
    }
    @IBAction func rotate(_ sender: Any) {
        delegate?.didSelect(option: .rotate)
    }
    @IBAction func original(_ sender: Any) {
        delegate?.didSelect(option: .original)
    }
    
}
