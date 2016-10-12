//
//  CellAdditions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

protocol IdentifiableCell {
    // We use func instead of a static var to allow subclasses to override the returned value.
    static func cellIdentifier() -> String
}

protocol IdentifiableNibBasedCell: IdentifiableCell {
    static func nib() -> UINib
}

extension IdentifiableNibBasedCell {
    static func nib() -> UINib {
        return UINib(nibName: self.cellIdentifier(), bundle: Bundle.main)
    }
}

extension UITableView {
    
    // Usage:
    //
    // In viewDidLoad or wherever:
    //		tableView.registerIdentifiableCell(SomeClass)
    //
    // In cellForRowAtIndexPath:
    //		let cell = tableView.dequeueIdentifiableCell(SomeClass)
    
    func registerIdentifiableCell<T: UITableViewCell>(_ cellClass: T.Type) where T: IdentifiableCell {
        if let nibBasedCellClass = cellClass as? IdentifiableNibBasedCell.Type {
            self.register(nibBasedCellClass.nib(), forCellReuseIdentifier: nibBasedCellClass.cellIdentifier())
        } else {
            self.register(cellClass, forCellReuseIdentifier: cellClass.cellIdentifier())
        }
    }
    
    func dequeueIdentifiableCell<T: UITableViewCell>(_ cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T where T: IdentifiableCell {
        return self.dequeueReusableCell(withIdentifier: cellClass.cellIdentifier(), for: indexPath) as! T
    }
}

extension UICollectionView {
    
    // Usage:
    //
    // In viewDidLoad or wherever:
    //		collectionView.registerIdentifiableCell(SomeClass)
    //
    // In cellForItemAtIndexPath:
    //		let cell = collectionView.dequeueIdentifiableCell(SomeClass.self, atIndexPath: indexPath)
    
    func registerIdentifiableCell<T: UICollectionViewCell>(_ cellClass: T.Type) where T: IdentifiableCell {
        if let nibBasedCellClass = cellClass as? IdentifiableNibBasedCell.Type {
            self.register(nibBasedCellClass.nib(), forCellWithReuseIdentifier: nibBasedCellClass.cellIdentifier())
        } else {
            self.register(cellClass, forCellWithReuseIdentifier: cellClass.cellIdentifier())
        }
    }
    
    func dequeueIdentifiableCell<T: UICollectionViewCell>(_ cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T where T: IdentifiableCell {
        return self.dequeueReusableCell(withReuseIdentifier: cellClass.cellIdentifier(), for: indexPath) as! T
    }
}
