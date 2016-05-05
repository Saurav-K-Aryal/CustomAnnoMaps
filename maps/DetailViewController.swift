//
//  DetailViewController.swift
//  CustomAnnoMaps
//
//  Created by Saurav Koirala on 3/8/16.
//  Copyright © 2016 Saurav Aryal. All rights reserved.import



import UIKit

class DetailViewController: UIViewController {
    
   
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var subtitleView: UILabel!
    @IBOutlet weak var placeIdView: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    
    var detaillocation = mapLocation()
    
    var image: String?
    
    override func viewDidLoad() {
        
//        print(detaillocation.title)
//        print(detaillocation.coordinate.latitude)
//        print(detaillocation.coordinate.longitude)
//        print(detaillocation.placeId)
        titleView.text = detaillocation.title
        subtitleView.text = String(detaillocation.coordinate.latitude) + " " + String(detaillocation.coordinate.longitude)
        placeIdView.text = detaillocation.placeId
        
        if let url = NSURL(string: detaillocation.image!) {
            // print(data)
            // print(data.image)
            if let data = NSData(contentsOfURL: url) {
                mImageView.image = UIImage(data: data)
            }
        }
        super.viewDidLoad()
        
    }
    

    
    
}