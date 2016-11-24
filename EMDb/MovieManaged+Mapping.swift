//
//  MovieManaged+Mapping.swift
//  EMDb
//
//  Created by Xavi Moll on 24/11/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import Foundation

extension MovieManaged {
    
    func mappedObject() -> Movie {
        return Movie(id: self.id, title: self.title, order: Int(self.order), summary: self.summary, image: self.image, category: self.category, director: self.director)
    }
    
}
