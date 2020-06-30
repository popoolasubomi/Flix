//
//  OAPMovieFetcher.h
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/26/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OAPMovieFetcher : NSObject

@property (nonatomic, strong) NSArray *movies;

+ (OAPMovieFetcher *)sharedObject;
- (void)fetchMoviesWithCompletionHandler:(void(^)(NSArray*))completionHandler;

@end

NS_ASSUME_NONNULL_END
