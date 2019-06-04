//
//  NavigationController.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import  UIKit

class NavigationController: UINavigationController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let vc = topViewController {
                return vc.shouldAutorotate
            } else {
                return super.shouldAutorotate
            }
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = topViewController {
                return visibleVC.supportedInterfaceOrientations
            } else {
                return super.supportedInterfaceOrientations
            }
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            if let visibleVC = topViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            } else {
                return super.preferredInterfaceOrientationForPresentation
            }
        }
    }
    
    func adjustOrientationIfNeeded() {
        if self.supportedInterfaceOrientations.misses(currentOrientation()) {
            UIDevice.current
                .setValue(self.preferredInterfaceOrientationForPresentation.rawValue,
                          forKey: "orientation")
        }
    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        adjustOrientationIfNeeded()
    }
}

extension UIInterfaceOrientationMask {
    func supports(_ orientation: UIInterfaceOrientation) -> Bool {
        return (orientation.isLandscape && self.contains(.landscape))
            || (orientation.isPortrait && self.contains(.portrait))
    }
    
    func misses(_ orientation: UIInterfaceOrientation) -> Bool {
        return !supports(orientation)
    }
    
    public var description: String {
        switch self {
        case .all:
            return "all"
        case .allButUpsideDown:
            return "allButUpsideDown"
        case .landscape:
            return "landscape"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        default:
            return "Unkown UIInterfaceOrientationMask"
        }
    }
}

extension UIInterfaceOrientation {
    public var description: String {
        switch self {
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .unknown:
            return "unknown"
        }
    }
    
    func toMask() -> UIInterfaceOrientationMask {
        return self.isPortrait ? .portrait : .landscape
    }
}


/// iOS v9.* has a bug that requires this extension, otherwise the app crashes
/// with the following message:
/// "UIAlertController:supportedInterfaceOrientations was invoked recursively"
/// Read more at https://stackoverflow.com/a/32010520/10070651.
extension UIAlertController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // By having the alert supporting only the current orientation, we make sure
        // that we don't override the parent view controller supported orientations.
        // This is fine for users too since they were already in this orientation.
        return currentOrientation().toMask()
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
}
