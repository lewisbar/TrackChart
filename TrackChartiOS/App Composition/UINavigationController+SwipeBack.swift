//
//  UINavigationController+SwipeBack.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 28.10.25.
//
//  Source: https://www.reddit.com/r/SwiftUI/comments/1g0pmst/comment/mx2sy0s/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

import SwiftUI

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    // Allows swipe back gesture after hiding standard back button with .navigationBarBackButtonHidden(true)
    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard viewControllers.count > 1 else { return false }

        // Prevent gesture conflicts during sheet presentation
        // Check if any presented view controller exists
        if presentedViewController != nil {
            return false
        }

        return true
    }

    // Allows interactivePopGestureRecognizer to work simultaneously with other gestures.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    // Blocks other gestures when interactivePopGestureRecognizer begins (my TabView scrolled together with screen swiping back)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
