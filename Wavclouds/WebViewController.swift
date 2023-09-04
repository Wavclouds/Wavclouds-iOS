//
//  WebViewController.swift
//  Wavclouds
//
//  Created by Enoch Tamulonis on 9/3/23.
//
//
//  WebViewController.swift
//  turboiosexample
//
//  Created by Dave Kimura on 3/6/21.
//

import UIKit
import Turbo

class WebViewController: VisitableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func visitableDidRender() {
        title = "Wavclouds"
    }
}
