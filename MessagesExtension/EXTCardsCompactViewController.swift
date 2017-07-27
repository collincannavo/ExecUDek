//
//  EXTCardsCompactViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class EXTCardsCompactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "extCardCell", for: indexPath) as? EXTCardTableViewCell else { return EXTCardTableViewCell() }
        
        switch indexPath.row {
        case 0:
            guard let image = UIImage(named: "businessCard1") else { return cell }
            cell.updateCell(with: image)
        case 1:
            guard let image = UIImage(named: "businessCard2") else { return cell }
            cell.updateCell(with: image)
        case 2:
            guard let image = UIImage(named: "businessCard3") else { return cell }
            cell.updateCell(with: image)
        default:
            return cell
        }
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
