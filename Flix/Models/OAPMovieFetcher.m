//
//  OAPMovieFetcher.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/26/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "OAPMovieFetcher.h"

@implementation OAPMovieFetcher

+ (OAPMovieFetcher *)sharedObject {
    static OAPMovieFetcher *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
    });
    return sharedClass;
}

- (void) fetchMovies {
    NSLog(@"Fetching");
}

@end
