//
//  ViewAnimator.swift
//  parte3IOS
//
//  Created by Laura Corssac on 21/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import Foundation

enum ContainerState {
    case hidden, visible
    
    var height: CGFloat {
        switch self {
        case .hidden:
            return 0
        case .visible:
            return 500
        }
    }
    mutating func change() {
        self = self == .hidden ? .visible : .hidden
    }
    
}

class ViewAnimator {
    
    private weak var headerView: UIView?
    private weak var constraint: NSLayoutConstraint?
    private weak var mainView: UIView?
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    
    var state: ContainerState = .hidden

    init(mainView: UIView, viewToTap: UIView, heightConstraint: NSLayoutConstraint) {
        self.headerView = viewToTap
        self.constraint = heightConstraint
        self.mainView = mainView
        headerView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMenu(_:))))
    }
    
    @objc func didTapMenu(_: UIGestureRecognizer) {
        animateMenu()
    }
    
    func animateMenu() {
        self.state.change()
        self.animator.addAnimations { [weak self] in
            self?.constraint?.constant = self?.state.height ?? 0
            self?.mainView?.layoutIfNeeded()
        }
        self.animator.startAnimation()
    }
    
}
