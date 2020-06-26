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
    
    NSString *posterUrlString = self.movie[@"poster_path"];
    NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat:posterUrlString];
    NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
    [self.posterView setImageWithURL: posterUrl];
    
    NSString *backdropUrlString = self.movie[@"backdrop_path"];
    NSString *smallFullBackdropUrlString = [smallBaseUrlString stringByAppendingFormat: backdropUrlString];
    NSString *largeFullBackdropUrlString = [baseUrlString stringByAppendingFormat: backdropUrlString];
//    NSURL *backdropUrl = [NSURL URLWithString:fullBackdropUrlString];
//    [self.backdropView setImageWithURL:backdropUrl];
    NSURL *urlSmall = [NSURL URLWithString: smallFullBackdropUrlString];
    NSURL *urlLarge = [NSURL URLWithString: largeFullBackdropUrlString];

    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];

    __weak DetailsViewController *weakSelf = self;

    [self.backdropView setImageWithURLRequest:requestSmall
      placeholderImage:nil
               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                   
                   // smallImageResponse will be nil if the smallImage is already available
                   // in cache (might want to do something smarter in that case).
                   weakSelf.backdropView.alpha = 0.0;
                   weakSelf.backdropView.image = smallImage;
                   
                   [UIView animateWithDuration: 1
                                    animations:^{
                                        
                       weakSelf.backdropView.alpha = 1.0;
                       
                   } completion:^(BOOL finished) {
                       // The AFNetworking ImageView Category only allows one request to be sent at a time
                       // per ImageView. This code must be in the completion block.
                       [weakSelf.backdropView setImageWithURLRequest:requestLarge
                                                    placeholderImage:smallImage
                                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                           weakSelf.backdropView.image = largeImage;
                       }
                                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                           // do something for the failure condition of the large image request
                           // possibly setting the ImageView's image to a default image
                                                                       }];
                                    }];
               }
               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"Didn't work...");
               }];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    self.releaseDate.text = self.movie[@"release_date"];
    self.rating.text = [NSString stringWithFormat: @"%@", self.movie[@"vote_average"]];
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    [self.rating sizeToFit];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        WebKitViewController *webKitViewController = [segue destinationViewController];
        webKitViewController.movie = self.movie;
}


@end
