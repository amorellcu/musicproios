//
//  PackagesViewController.swift
//  musicprof
//
//  Created by Alexis Morell on 03/05/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit

class PackagesViewController: UIViewController {
    
    var Perfilname = ""
    var Photo = UIImage()
    
    @IBOutlet weak var PerfilPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PerfilPhoto.image = Photo
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
