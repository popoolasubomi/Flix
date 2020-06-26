//
//  OAPMovieFetcher.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/26/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "OAPMovieFetcher.h"

@implementation OAPMovieFetcher

typedef void(^completion)(NSDictionary*);

+ (OAPMovieFetcher *)sharedObject {
    static OAPMovieFetcher *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
    });
    return sharedClass;
}

- (void) fetchMoviesWithCompletionHandler:(void (^)(NSArray * _Nonnull))completionHandler {
    if (self.movies){
        completionHandler(self.movies);
    }
    else{
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               completionHandler(nil);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.movies = dataDictionary[@"results"];
               completionHandler(self.movies);
           }
       }];
        [task resume];
        
    }
}

@end
