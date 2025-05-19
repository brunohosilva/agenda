//
//  SpyMySchedulesViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 19/05/25.
//

import UIKit

class SpyMySchedulesViewController: MySchedulesViewController {
    var presentedViewControllerSpy: UIViewController?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllerSpy = viewControllerToPresent
        super.present(viewControllerToPresent, animated: false, completion: completion)
    }
}
