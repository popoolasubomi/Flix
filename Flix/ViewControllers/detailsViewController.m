//
//  detailsViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WebKitViewController.h"
#import "Movie.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDate;
@property (weak, nonatomic) IBOutlet UILabel *rating;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewController];
}

- (void) updateViewController{
    NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
    NSString *smallBaseUrlString = @"https://image.tmdb.org/t/p/w200";
    
    NSString *posterUrlString = self.movie.posterUrlString;
    NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat:posterUrlString];
    NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
    [self.posterView setImageWithURL: posterUrl];
    
    if ([self.movie.backdropPath isKindOfClass:[NSString class]]){
        NSString *backdropUrlString = self.movie.backdropPath;
        NSString *smallFullBackdropUrlString = [smallBaseUrlString stringByAppendingFormat: backdropUrlString];
        NSString *largeFullBackdropUrlString = [baseUrlString stringByAppendingFormat: backdropUrlString];
        NSURL *urlSmall = [NSURL URLWithString: smallFullBackdropUrlString];
        NSURL *urlLarge = [NSURL URLWithString: largeFullBackdropUrlString];

        NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
        NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];

        __weak DetailsViewController *weakSelf = self;

        [self.backdropView setImageWithURLRequest:requestSmall
          placeholderImage:nil
                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                       weakSelf.backdropView.alpha = 0.0;
                       weakSelf.backdropView.image = smallImage;
                       
                       [UIView animateWithDuration: 1
                                        animations:^{
                                            
                           weakSelf.backdropView.alpha = 1.0;
                           
                       } completion:^(BOOL finished) {
                           [weakSelf.backdropView setImageWithURLRequest:requestLarge
                                                        placeholderImage:smallImage
                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                               weakSelf.backdropView.image = largeImage;
                           }
                                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                           }];
                                        }];
                   }
                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        NSLog(@"Didn't work...");
        }];
        
    }else{
        self.backdropView.image = nil;
    }
    
    self.titleLabel.text = self.movie.title;
    self.synopsisLabel.text = self.movie.overview;
    self.releaseDate.text = self.movie.releaseDate;
    self.rating.text = [NSString stringWithFormat: @"%@", self.movie.rating];
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    [self.rating sizeToFit];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        WebKitViewController *webKitViewController = [segue destinationViewController];
        webKitViewController.movie = self.movie;
}


@end
