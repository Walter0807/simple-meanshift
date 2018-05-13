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
    let pictures = ["fruit", "icecream", "tower", "luxun"]
    var idx = 0
    let meanshift = Meanshift(3)
    
    @IBOutlet weak var gtlabel: UILabel!
    @IBOutlet weak var gtslider: UISlider!
    @IBOutlet weak var running: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        image1.image = UIImage(named: pictures[idx])
    }
    @IBAction func runAlgo(_ sender: UIButton) {
        //        running.isHidden = false
        DispatchQueue.main.async {
            self.running.startAnimating()
        }
        var resultimg = UIImage()
        DispatchQueue.global().async {
            resultimg = self.meanshift.run(UIImage(named: self.pictures[self.idx])!)
            DispatchQueue.main.async {
                self.gtlabel.isHidden = false
                self.gtslider.isHidden = false
                self.image2.image = resultimg
                self.running.stopAnimating()

            }
        }

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
