//
//  DateTimePickerViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/7/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class DateTimePickerViewController: UIViewController {
    @IBOutlet weak var pickerView: UIDatePicker!
    
    var onDateSelected: ((Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.pickerView.backgroundColor = UIColor.white
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true) { () -> Void in
            if let onDateSelected = self.onDateSelected {
                onDateSelected(self.pickerView.date)
            }
        }
    }
}
