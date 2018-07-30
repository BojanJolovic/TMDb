//
//  AnAppViewController.swift
//  TMDb
//
//  Created by Bojan Jolovic on 25/07/2018.
//  Copyright © 2018 Bojan Jolovic. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class AnAppViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK: - Variable
    var movieTitle = [String]()
    var movieBackdrop = [String]()
    var moviePoster = [String]()
    var movieOverview = [String]()
    var tvName = [String]()
    var tvBackdrop = [String]()
    var tvPoster = [String]()
    var tvOverview = [String]()
    var filterData = [String]()
    var inSearchMode = false
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 96.0
        loadData()
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    func loadData(forSearch: Bool = false) {
        
        //Create URL
        let str = createUrl(search: forSearch)
        let url: URL = URL(string: str)!
        
        //Load TDMb request
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success:
                let jsonValue = response.result.value as! NSDictionary
                
                //Only value from key results in JSON
                if let data = jsonValue["results"] as? [NSDictionary] {
                    var numberOfIteration = 1 // JSON has 20 element, app needs 10, when the input of the data 10, will stop the for loop
                    
                    for object in data {
                        if numberOfIteration < 11 {
                            
                            switch segmentedControlValue {
                            case 0: //For Movie
                                self.movieTitle.append(object.value(forKey: "title") as! String)
                                self.movieBackdrop.append(object.value(forKey: "backdrop_path") as! String)
                                self.moviePoster.append(object.value(forKey: "poster_path") as! String)
                                self.movieOverview.append(object.value(forKey: "overview") as! String)
                                
                            case 1: //For TVShow
                                self.tvName.append(object.value(forKey: "name") as! String)
                                self.tvBackdrop.append(object.value(forKey: "backdrop_path") as! String)
                                self.tvPoster.append(object.value(forKey: "poster_path") as! String)
                                self.tvOverview.append(object.value(forKey: "overview") as! String)
                                
                            default:
                                break
                            }
                            
                            numberOfIteration += 1
                        } else { // When input 10 Movie/TVShow stop the for loop
                            self.tableView.reloadData()
                            self.tableView.isHidden = false
                            break
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func createUrl(search: Bool) -> String {
        var forStr: String = "movie"
        switch segmentedControlValue {
        case 0:
            forStr = "movie"
        case 1:
            forStr = "tv"
        default:
            break
        }
        
        let str = BASE_URL + forStr + API_KEY
        
        return str
    }
    
    //MARK: - IBAction
    @IBAction func segmentControlChange(_ sender: UISegmentedControl) {
        //If data is empty, call load function, after in next call jut reload tableView
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentedControlValue = 0
            if movieTitle.count != 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.isHidden = true
                loadData()
            }
        case 1:
            segmentedControlValue = 1
            if tvName.count != 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.isHidden = true
                loadData()
            }
        default:
            break
        }
    }
    
    //MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text! == "" {
            inSearchMode = false
            segmentedControl.isEnabled = true
            view.endEditing(true)
            tableView.reloadData()
        } else {
            inSearchMode = true
            segmentedControl.isEnabled = false
            switch segmentedControlValue {
            case 0:
                filterData = movieTitle.filter({$0.contains(searchBar.text!)})
            case 1:
                filterData = tvName.filter({$0.contains(searchBar.text!)})
            default:
                break
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 0
        
        if inSearchMode {
            return filterData.count
        }
        
        switch segmentedControlValue {
        case 0 :
            numberOfRow = movieTitle.count
        case 1:
            numberOfRow = tvName.count
        default:
            break
        }
        
        
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: anAppCellID, for: indexPath) as! AnAppTableViewCell
        
        var title = ""
        let number = String(indexPath.row + 1)
        var imgStr = ""
        
        if inSearchMode {
            title = filterData[indexPath.row]
            let correctIndex = movieTitle.index(of:filterData[indexPath.row])
            switch segmentedControlValue {
            case 0:
                let correctIndex = movieTitle.index(of:filterData[indexPath.row])
                imgStr = BASE_URL_IMG + movieBackdrop[correctIndex!]
            case 1:
                let correctIndex = tvName.index(of:filterData[indexPath.row])
                imgStr = BASE_URL_IMG + tvBackdrop[correctIndex!]
            default:
                break
            }
        } else {
            switch segmentedControlValue {
            case 0:
                title = movieTitle[indexPath.row]
                imgStr = BASE_URL_IMG + movieBackdrop[indexPath.row]
            case 1:
                title = tvName[indexPath.row]
                imgStr = BASE_URL_IMG + tvBackdrop[indexPath.row]
            default:
                break
            }
        }

        let imgUrl = URL(string: imgStr)
        
        cell.titleLabel.text = title
        cell.numberLabel.text = number
        cell.imageViewBG.kf.setImage(with: imgUrl)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: aboutViewControllerID) as! AboutViewController
        
        if inSearchMode {
            
            
            switch segmentedControlValue {
            case 0:
                let correctIndex = movieTitle.index(of:filterData[indexPath.row])
                aboutVC.imageStr = BASE_URL_IMG + moviePoster[correctIndex!]
                aboutVC.titleStr = movieTitle[correctIndex!]
                aboutVC.overview = movieOverview[correctIndex!]
            case 1:
                let correctIndex = tvName.index(of:filterData[indexPath.row])
                aboutVC.imageStr = BASE_URL_IMG + tvPoster[correctIndex!]
                aboutVC.titleStr = tvName[correctIndex!]
                aboutVC.overview = tvOverview[correctIndex!]
            default:
                break
            }
        } else {
            switch segmentedControlValue {
            case 0:
                aboutVC.imageStr = BASE_URL_IMG + moviePoster[indexPath.row]
                aboutVC.titleStr = movieTitle[indexPath.row]
                aboutVC.overview = movieOverview[indexPath.row]
            case 1:
                aboutVC.imageStr = BASE_URL_IMG + tvPoster[indexPath.row]
                aboutVC.titleStr = tvName[indexPath.row]
                aboutVC.overview = tvOverview[indexPath.row]
            default:
                break
            }
        }
        
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}
