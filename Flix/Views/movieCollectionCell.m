//
//  movieCollectionCell.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "Movie.h"
@implementation MovieCollectionCell

- (void)setMovie:(Movie *)movie{
    self.posterView.image = nil;
    NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterUrlString =  movie.posterUrlString;
    NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat: posterUrlString];
    NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:posterUrl];
    __weak UIImageView *weakImageView = self.posterView;
    [self.posterView setImageWithURLRequest: request placeholderImage:nil
    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
        if (imageResponse) {
            weakImageView.alpha = 0.0;
            weakImageView.image = image;
            
            [UIView animateWithDuration:6 animations:^{
                weakImageView.alpha = 1.0;
            }];
        }
        else {
            weakImageView.image = image;
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
        NSLog(@"Process Failed..."); }];
}

@end
