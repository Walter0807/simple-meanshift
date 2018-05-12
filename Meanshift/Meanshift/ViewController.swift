//
//  ViewController.swift
//  Meanshift
//9ijh8
//  Created by Walter on 5/12/18.
//  Copyright © 2018 朱文韬. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    public let originalImage = UIImage(named: "tower")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image1.image = originalImage
    }
    
    @IBAction func runAlgo(_ sender: UIButton) {
        let meanshift = Meanshift(20)
        image2.image = meanshift.run(originalImage!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
