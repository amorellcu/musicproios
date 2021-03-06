//
//  ImageImporter.swift
//  musicprof
//
//  Created by John Doe on 7/3/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FacebookCore
import AlamofireImage

class ImageImporter {
    let viewController: UIViewController
    var delegates = [PickerDelegate]()
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func getPicture(for user: User, completion: @escaping () -> ()) {
        let title = "Cambiar imagen"
        let delegate = PickerDelegate(importer: self, user: user, callback: completion)
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller.addAction(UIAlertAction(title: "Mis fotos", style: .default) { action in
                self.selectImageFromGallery(delegate: delegate)
            })
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.addAction(UIAlertAction(title: "Tomar foto", style: .default) { action in
                self.recordImageWithCamera(delegate: delegate)
            })
        }
        if user.facebookId != nil && AccessToken.current != nil  {
            controller.addAction(UIAlertAction(title: "Mi foto de Facebook", style: .default) { action in
                self.getPictureFromFB(for: user, completion: completion)
            })
        }
        controller.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.viewController.view
            let bounds = self.viewController.view.bounds
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.viewController.present(controller, animated: true)
    }
    
    
    
    func getPictureFromFB(for user: User, completion: @escaping () -> ()) {
        let fbClient = Client()
        fbClient.loadFromFB { (error) in
            if let error = error {
                self.viewController.notify(error: error)
            } else if let avatarUrl = fbClient.avatarUrl {
                let request = URLRequest(url: avatarUrl)
                ImageDownloader.default.download([request]) { response in
                    if let avatar = response.result.value, PickerDelegate.updatePicture(of: user, with: avatar) {
                        completion()
                    } else {
                        self.viewController.notify(message: "No se pudo descargar la foto.", title: "Error")
                    }
                }
            } else {
                self.viewController.notify(message: "No se pudo obtener su foto de Facebook.", title: "Error")
            }
        }
    }
    
    func selectImageFromGallery(delegate: PickerDelegate) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        self.delegates.append(delegate)
        self.viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    func recordImageWithCamera(delegate: PickerDelegate) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image"]
        self.delegates.append(delegate)
        self.viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    class PickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        unowned var imageImporter: ImageImporter!
        let callback: () -> ()
        let user: User
        
        init(importer: ImageImporter, user: User, callback: @escaping () -> ()) {
            self.user = user
            self.callback = callback
            self.imageImporter = importer
            super.init()
        }
        
        static func updatePicture(of user: User, with image: UIImage) -> Bool {
            guard let data = UIImageJPEGRepresentation(image, 0.85) else { return false }
            let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent("\(UUID()).jpg")
            if !FileManager.default.createFile(atPath: destinationURL.path, contents: data, attributes: nil) {
                return false
            }
            user.avatarUrl = destinationURL
            return true
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            picker.dismiss(animated: true, completion: nil)
            
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage,
                PickerDelegate.updatePicture(of: user, with: image) {
                self.callback()
            }
            
            self.imageImporter.delegates.removeAll(where: {$0 === self})
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.imageImporter.delegates.removeAll(where: {$0 === self})
        }
    }
}
