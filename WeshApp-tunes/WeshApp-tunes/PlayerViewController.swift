//
//  PlayerViewController.swift
//  WeshApp-tunes
//
//  Created by z.kakabadze on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

  var songTitle:String?

    override func viewDidLoad() {
        super.viewDidLoad()  
        println(songTitle!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
