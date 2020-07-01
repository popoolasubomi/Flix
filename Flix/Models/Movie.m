//
//  Movie.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 7/1/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    self.title = dictionary[@"title"];
    self.overview = dictionary[@"overview"];
    self.posterUrlString = dictionary[@"poster_path"];
    self.backdropPath = dictionary[@"backdrop_path"];
    self.releaseDate = dictionary[@"release_date"];
    self.rating = dictionary[@"vote_average"];
    self.id_str = dictionary[@"id"];
    return self;
}

@end
