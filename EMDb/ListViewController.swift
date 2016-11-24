//
//  ListViewController.swift
//  EMDb
//
//  Created by Xavi Moll on 24/11/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit
import Kingfisher

class ListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies = [Movie]()
    var collectionViewPadding: CGFloat = 0
    let refresh = UIRefreshControl()
    let dataProvider = LocalCoreDataService()
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchBar.delegate = self
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        loadData()
        refresh.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        collectionView.refreshControl?.tintColor = UIColor.white
        collectionView.refreshControl = refresh
        
        setCollectionViewPadding()
    }
    
    func setCollectionViewPadding() {
        let screenWidth = self.view.frame.width
        collectionViewPadding = (screenWidth - (3*113)) / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionViewPadding, left: collectionViewPadding, bottom: collectionViewPadding, right: collectionViewPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        self.configureCell(cell, withMovie: movie)
        return cell
    }
    
    func configureCell(_ cell: MovieCell, withMovie movie: Movie) {
        if let imageData = movie.image {
            cell.movieImage.kf.setImage(with: ImageResource(downloadURL: URL(string: imageData)!), placeholder: #imageLiteral(resourceName: "img-loading"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 113, height: 170)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(self.tapGesture)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            loadData()
        }
    }
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
        self.view.removeGestureRecognizer(self.tapGesture)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let term = searchBar.text {
            dataProvider.searchMovies(byTerm: term) { movies in
                if let movies = movies {
                    self.movies = movies
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        searchBar.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    func loadData() {
        dataProvider.getTopMovies(localHandler: { movies in
            if let movies = movies {
                self.movies = movies
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                print("No hay registro en Core Data")
            }
        }, remoteHandler: { movies in
            if let movies = movies {
                self.movies = movies
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.refresh.endRefreshing()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPathSelected = collectionView.indexPathsForSelectedItems?.last {
                let selectedMovie = movies[indexPathSelected.row]
                let detailVC = segue.destination as! MovieViewController
                detailVC.movie = selectedMovie
            }
            hideKeyboard()
        }
    }
}
