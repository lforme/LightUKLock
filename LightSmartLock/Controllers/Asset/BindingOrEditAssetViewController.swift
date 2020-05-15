//
//  BindingOrEditAssetViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/15.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BindingOrEditAssetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CitySelectViewController,
            let btn = sender as? UIButton
            {
            vc.didSelectCitt = { city in
                btn.setTitle(city.name, for: .normal)
            }
        }
    }
    
}
