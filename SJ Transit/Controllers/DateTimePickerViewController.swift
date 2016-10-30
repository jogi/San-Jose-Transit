//
//  DateTimePickerViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/7/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import Crashlytics

class DateTimePickerViewController: UIViewController {
    @IBOutlet weak var pickerView: UIDatePicker!
    
    var onDateSelected: ((Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.pickerView.backgroundColor = UIColor.white
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEvent(withName: "Show Date Picker", customAttributes: ["parent": "\(self.parent)" ])
    }
    
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true) { () -> Void in
            if let onDateSelected = self.onDateSelected {
                onDateSelected(self.pickerView.date)
            }
        }
    }
}
