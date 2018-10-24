//
//  MenuViewController.swift
//  parte3IOS
//
//  Created by Laura Corssac on 21/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

enum MenuOption: Int {
    case contrast = 0
    case negative = 1
    case brightness = 2
    case flipVertical = 4
    case flipHorizontal = 5
    case grayScale = 6
    case startRecording = 7
    case sobel = 9
    case canny = 10
    case gaussianBlur = 11
    case rotate = 12
    case scale = 13
}
protocol ControlVCDelegate: class {
    func didSelect(option: MenuOption)
    func didDeselect(option: MenuOption)
}

class MenuViewController: UIViewController {
    
    weak var delegate: ControlVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender.isSelected {
            delegate?.didDeselect(option: MenuOption(rawValue: sender.tag)!)
        } else {
            delegate?.didSelect(option: MenuOption(rawValue: sender.tag)!)
        }
        sender.isSelected = !sender.isSelected
    }
}
    

