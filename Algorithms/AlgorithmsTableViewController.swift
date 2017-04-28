//
//  AlgorithmsTableViewController.swift
//  Algorithms
//
//  Created by Roberto Fierro Martinez on 4/20/17.
//  Copyright © 2017 Roberto Fierro Martinez. All rights reserved.
//

import UIKit

class AlgorithmsTableViewController: UITableViewController {
    
    let sections = ["Sort", "List Search", "Graph Search"]
    let algorithms = ["Sort" : ["Insertion Sort", "Merge Sort", "Quick Sort"],
                      "List Search" : ["Binary Search"],
                      "Graph Search" : ["Breadth First Search", "Depth First Search", "Distance Search"]]
    let colors = [
        UIColor.init(colorLiteralRed: 178/255, green: 162/255, blue: 237/255, alpha: 1.0),
        UIColor.init(colorLiteralRed: 235/255, green: 216/255, blue: 83/255, alpha: 1.0),
        UIColor.init(colorLiteralRed: 77/255, green: 173/255, blue: 85/255, alpha: 1.0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Algorithms"
        self.view.backgroundColor = .white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return self.sections[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let list = self.algorithms[self.sections[section]] {
            return list.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor = self.colors[section]
        header.textLabel?.font = .boldSystemFont(ofSize: (header.textLabel?.font.pointSize)!)
        header.textLabel?.textColor = .black
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AlgorithmCell", for: indexPath)

        if let list = self.algorithms[self.sections[indexPath.section]] {
            
            cell.textLabel?.text = list[indexPath.row]
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlgorithm",
            let nextScene = segue.destination as? AlgorithmViewController,
            let indexPath = self.tableView.indexPathForSelectedRow {
            
            if let list = self.algorithms[self.sections[indexPath.section]] {
                
                let selectedAlgorithm = list[indexPath.row]
                
                switch (selectedAlgorithm) {
                    case "Insertion Sort" :
                        nextScene.title = selectedAlgorithm
                        break;
                    default:
                        break;
                }
            }
            
        }
        
    }
    

}
