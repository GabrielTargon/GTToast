//
//  ViewController.swift
//  GTToast
//
//  Created by Gabriel Targon on 28/05/20.
//  Copyright © 2020 Gabriel Targon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var viewTest: UIView!
    @IBOutlet weak var textField: UITextField!
    
    var toast = GTToast.start()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: GTToast
    
    @IBAction func callToast(_ sender: Any) {
        toast.show(withText: "Toast de teste", withCloseButton: true, andBackgroundColor: .yellow)
    }
    
    @IBAction func callToastRed(_ sender: Any) {
        toast.show(withText: "Toast de teste", withCloseButton: true, andBackgroundColor: .red)
    }
    
    @IBAction func callToastGreen(_ sender: Any) {
        toast.show(withText: "Toast de teste", withCloseButton: true, andBackgroundColor: .green)
        toast.hideAfter(seconds: 3)
    }
    
    @IBAction func dismissKeybaord(_ sender: Any) {
        textField.resignFirstResponder()
    }


}

