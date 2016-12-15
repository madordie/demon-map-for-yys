//
//  ViewController.swift
//  Search-Yinyangshi
//
//  Created by 孙继刚 on 2016/12/15.
//  Copyright © 2016年 madordie. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    let heightCell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell")
    var source = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var infos = [(show: String, key: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTableView))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
        do {
            let content = try String(contentsOfFile: Bundle.main.path(forResource: "info", ofType: "txt") ?? "")
            for line in content.components(separatedBy: CharacterSet(charactersIn: "\n")) {
                let key = line
                let show = line.replacingOccurrences(of: " -> ", with: "\t\n")
                infos.append((show: show, key: key))
            }
        } catch {
            source.append("\(error)")
        }
        
        searchBar.delegate?.searchBar?(searchBar, textDidChange: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapTableView() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        source.removeAll()
        
        DispatchQueue(label: "search").async { [weak self] in
            if let strongSelf = self {
                var source = [String]()
                
                func search(_ text: String) {
                    for info in strongSelf.infos {
                        if info.key.contains(text) {
                            source.append(info.show)
                        }
                    }
                }
                
                search(searchText)
                
                if source.count == 0 {
                    search(" ")
                }
                
                DispatchQueue.main.async {
                    strongSelf.source = source
                }
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tapTableView()
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        fill(cell, indexPath: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        fill(heightCell, indexPath: indexPath)
        return heightCell.frame.height
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        if let string = source[indexPath.row].substring(fromStr: "--> ") {
            searchBar.text = string
            searchBar.delegate?.searchBar?(searchBar, textDidChange: searchBar.text ?? "")
        }
    }
    
    func fill(_ cell: UITableViewCell, indexPath: IndexPath) {
        cell.frame = tableView.bounds
        cell.textLabel?.text = source[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.sizeToFit()
    }
}

extension String {
    func substring(fromStr: String) -> String? {
        if let range = range(of: fromStr) {
            return substring(from: range.upperBound)
        }
        return nil
    }
}
