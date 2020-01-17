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
        UNUserNotificationCenter.current().delegate = self

        // Do any additional setup after loading the view.
        for controller in self.viewControllers ?? [] {
            if let nestedController = controller as? NestedController ??
                (controller as? UINavigationController)?.viewControllers.first as? NestedController {
                nestedController.container = self.container
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let message = appDelegate.openMessage, let classId = message.classId {
            appDelegate.openMessage = nil
            DispatchQueue.main.async { [weak self] in
                self?.openChat(forClassWithId: classId, withCompletionHandler: {
                    
                })
            }
        }
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
        openChat(forClassWithId: classId, withCompletionHandler: completionHandler)
    }
    
    func openChat(forClassWithId classId: Int, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard presentedViewController == nil else {
            print("Cannot open chat because the app is busy.")
            return completionHandler()
        }
        guard let index = viewControllers?.firstIndex(where: {$0 is ReservationListViewController}),
            let controller = viewControllers?[index] as? ReservationListViewController else {
            print("Could not find the class list controller.")
            return completionHandler()
        }
        self.selectedIndex = index
        ApiManager.shared.getClass(withId: classId) { [weak self, weak controller] (result) in
            self?.handleResult(result) { data in
                guard let reservation = data.reservations?.first ?? controller?.findClass(withId: classId)?.reservations?[0] else {
                    print("Could not find the class with id", classId)
                    return completionHandler()
                }
                controller?.performSegue(withIdentifier: "chatFromNotification", sender: reservation)
                completionHandler()
            }
        }
    }
}
