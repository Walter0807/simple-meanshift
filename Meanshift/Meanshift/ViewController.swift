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
    let pictures = ["pine", "fruit", "tower", "calendar", "icecream"]
    var idx = 0
    let meanshift = Meanshift(3)
    
    @IBOutlet weak var gtlabel: UILabel!
    @IBOutlet weak var gtslider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image1.image = UIImage(named: pictures[idx])
    }
    
    @IBAction func runAlgo(_ sender: UIButton) {
        image2.image = meanshift.run(image1.image!)
        gtlabel.isHidden = false
        gtslider.isHidden = false
    }
    
    @IBAction func switchPicture(_ sender: Any) {
        idx += 1
        if idx>=pictures.count {idx -= pictures.count}
        image1.image = UIImage(named: pictures[idx])
        image2.image = nil
        gtlabel.isHidden = true
        gtslider.isHidden = true
    }
    
    @IBAction func changeValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        image2.image = meanshift.adjust(image1.image!, currentValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
