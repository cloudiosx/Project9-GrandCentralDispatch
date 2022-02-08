//
//  ViewController.swift
//  Project7 - Whitehouse Petitions
//
//  Created by John Kim on 2/2/22.
//

import UIKit

class ViewController: UITableViewController {
    
//    var petitions = [String]()
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // UIBarButtonItem
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterPetitions))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showAlert))
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                // We're OK to parse!
                parse(json: data)
                return
            }
        }
        
        showError()
    }
    
    // Objective-C
    
    @objc func filterPetitions() {
        let ac = UIAlertController(title: "Enter a string", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let alertAction = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] _ in
            guard let filteredText = ac?.textFields?[0].text?.lowercased() else { return }
            self?.filter(filteredText)
        }
        
        ac.addAction(alertAction)
        present(ac, animated: true, completion: nil)
        filteredPetitions.removeAll() // https://stackoverflow.com/questions/31183431/swift-delete-all-array-elements
    }
    
    @objc func showAlert() {
        let ac = UIAlertController(title: "More info", message: "This data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    // Method
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    func filter(_ text: String) {
        for petition in petitions {
            if (petition.title.lowercased().contains(text) || petition.body.lowercased().contains(text)) {
                filteredPetitions.append(petition)
            }
        }
        tableView.reloadData()
    }
    
    // Error handling
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // Table view methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count > 0 ? filteredPetitions.count : petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (filteredPetitions.count > 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let filteredPetition = filteredPetitions[indexPath.row]
            cell.textLabel?.text = filteredPetition.title
            cell.detailTextLabel?.text = filteredPetition.body
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let petition = petitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
            /*
            cell.textLabel?.text = "Title goes here"
            cell.detailTextLabel?.text = "Subtitle goes here" // https://forums.raywenderlich.com/t/chapter-19-uitableviewcell-detailtextlabel-is-deprecated/132259
            */
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

