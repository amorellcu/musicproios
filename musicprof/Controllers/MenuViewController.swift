//
//  MenuViewController.swift
//  musicprof
//
//  Created by John Doe on 6/29/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class MenuViewController: UITabBarController, NestedController {
    weak var container: ContainerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        // Do any additional setup after loading the view.
        for controller in self.viewControllers ?? [] {
            if let nestedController = controller as? NestedController ??
                (controller as? UINavigationController)?.viewControllers.first as? NestedController {
                nestedController.container = self.container
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func lockCurrentSection() {
        guard let sections = self.tabBar.items else { return }
        for (index, item) in sections.enumerated() {
            item.isEnabled = self.selectedIndex == index
        }
    }
    
    func unlockAllSections() {
        guard let sections = self.tabBar.items else { return }
        for item in sections {
            item.isEnabled = true
        }
    }
    
    func gotoAccount() {
        guard let controller = self.viewControllers?.first else { return }
        self.selectedIndex = 0
        if let profile = controller as? ProfileUpdateViewController {
            profile.select(sectionAtIndex: 0, animated: true)
        } else if let navController = controller as? UINavigationController, let profile = navController.viewControllers.first as? ProfileUpdateViewController {
            profile.select(sectionAtIndex: 0, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NestedController ??
            (segue.destination as? UINavigationController)?.viewControllers.first as? NestedController {
            controller.container = self.container
        }
    }

}

extension MenuViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionCrossDissolve], completion: nil)
        }
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

extension MenuViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("[NOTIFICATION] \(response.actionIdentifier): \(userInfo)")
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return completionHandler() }
        guard let data = userInfo["message"] as? [String : AnyObject], let msg = Message(fromJSON: data), let classId = msg.classId else { return completionHandler() }
        guard presentedViewController == nil else { return }
        guard let index = viewControllers?.firstIndex(where: {$0 is ReservationListViewController}), let controller = viewControllers?[index] as? ReservationListViewController else { return completionHandler() }
        self.selectedIndex = index
        guard let reservation = controller.findClass(withId: classId)?.reservations?[0] else { return completionHandler() }
        controller.performSegue(withIdentifier: "chatFromNotification", sender: reservation)
        completionHandler()
    }
}
