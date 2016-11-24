//
//  FavoritesViewController.swift
//  EMDb
//
//  Created by Xavi Moll on 24/11/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit
import Kingfisher

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewPadding: CGFloat = 0
    let dataProvider = LocalCoreDataService()
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        setCollectionViewPadding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 113, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if movies.count > 0 {
            self.collectionView.backgroundView = nil
        } else {
            let imageView = UIImageView(image: UIImage(named: "sin-favoritas"))
            imageView.contentMode = .center
            self.collectionView.backgroundView = imageView
        }
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
    
    func loadData() {
        
        if let movies = dataProvider.getFavoriteMovies() {
            self.movies = movies
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPathSelected = collectionView.indexPathsForSelectedItems?.last {
                let selectedMovie = movies[indexPathSelected.row]
                let detailVC = segue.destination as! MovieViewController
                detailVC.movie = selectedMovie
            }
        }
    }
    

}
