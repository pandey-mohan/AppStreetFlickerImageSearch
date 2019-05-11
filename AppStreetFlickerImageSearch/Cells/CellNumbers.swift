//
//  CellNumbers.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import UIKit
protocol CellNumber{
    func sendNumberofcolumns(col: Int)
}
class CellNumbers: UIView,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var numberTableView: UITableView!
    var delegate:CellNumber?
    let cellNumbers:[Int] = [2,3,4]
    
    func initTableView(){
        //Registered Nib in order to use that.
        let cellNib = UINib(nibName: "SelectNumberTableViewCell", bundle: nil)
        numberTableView.register(cellNib, forCellReuseIdentifier: "numberCell")
        
        numberTableView.delegate = self
        numberTableView.dataSource = self
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = numberTableView.dequeueReusableCell(withIdentifier: "numberCell", for: indexPath) as! SelectNumberTableViewCell
        cell.textLabel?.text = "Set \(cellNumbers[indexPath.row]) Columns"
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.sendNumberofcolumns(col: cellNumbers[indexPath.row])
        self.removeFromSuperview()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellNumbers.count
    }
    

}
