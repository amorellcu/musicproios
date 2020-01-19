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
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let message = appDelegate.openMessage, let reservation = message.reservation {
            appDelegate.openMessage = nil
            DispatchQueue.main.async { [weak self] in
                self?.openChat(forReservation: reservation, withCompletionHandler: {
                    
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("[NOTIFICATION] \(userInfo)")
        if let data = userInfo["data"] as? [String: AnyObject], let msgData = data["message"] as? [String : AnyObject], let msg = Message(fromJSON: msgData) {
            if let chatController = self.presentedViewController as? ChatViewController, chatController.handleMessage(msg) {
                print("Ignoring message notification for the current chat session.")
                return completionHandler(.badge)
            } else {
                print("Showing message arrival notification.")
            }
        }
        return completionHandler([.badge, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("[NOTIFICATION] \(response.actionIdentifier): \(userInfo)")
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return completionHandler() }
        guard let data = userInfo["data"] as? [String: AnyObject], let msgData = data["message"] as? [String : AnyObject], let msg = Message(fromJSON: msgData), let reservation = msg.reservation else {
            print("Could not find reservation.")
            return completionHandler()
        }
        openChat(forReservation: reservation, withCompletionHandler: completionHandler)
    }
    
    func openChat(forReservation reservation: Reservation, withCompletionHandler completionHandler: @escaping () -> Void) {
        let classId = reservation.classId
        guard presentedViewController == nil else {
            print("Cannot open chat because the app is busy.")
            return completionHandler()
        }
        guard let children = viewControllers,
            let index = children.firstIndex(where: {
            $0 is ReservationListViewController ||
            ($0 as? UINavigationController)?.viewControllers.first is ReservationListViewController
        }), let controller = children[index] as? ReservationListViewController ??
            (children[index] as? UINavigationController)?.viewControllers.first as? ReservationListViewController else {
            print("Could not find the class list controller.")
            return completionHandler()
        }
        self.selectedIndex = index
        ApiManager.shared.getClass(withId: classId) { [weak self, weak controller] (result) in
            self?.handleResult(result) { data in
                var reservation = reservation
                reservation.classes = data
                controller?.performSegue(withIdentifier: "chatFromNotification", sender: reservation)
                completionHandler()
            }
        }
    }
}
