//
//  movieCell.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "movieCell.h"
#import "UIImageView+AFNetworking.h"

@implementation MovieCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setMovie:(Movie *)movie {
    _movie = movie;
    self.titleLabel.text = self.movie.title;
    self.synopsisLabel.text = self.movie.overview;

    self.posterView.image = nil;
    
    if (self.movie.posterUrlString != nil) {
        NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
        NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat: self.movie.posterUrlString];
        NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:posterUrl];
        __weak UIImageView *weakImageView = self.posterView;
        [self.posterView setImageWithURLRequest:request placeholderImage:nil
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
}

@end
