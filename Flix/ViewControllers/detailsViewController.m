//
//  detailsViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "detailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WebKitViewController.h"

@interface detailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDate;

@end

@implementation detailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewController];
}

- (void) updateViewController{
    NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterUrlString = self.movie[@"poster_path"];
    NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat:posterUrlString];
    NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
    [self.posterView setImageWithURL: posterUrl];
    
    NSString *backdropUrlString = self.movie[@"backdrop_path"];
    NSString *fullBackdropUrlString = [baseUrlString stringByAppendingFormat:backdropUrlString];
    NSURL *backdropUrl = [NSURL URLWithString:fullBackdropUrlString];
    [self.backdropView setImageWithURL:backdropUrl];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    self.releaseDate.text = self.movie[@"release_date"];
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        WebKitViewController *webKitViewController = [segue destinationViewController];
        webKitViewController.movie = self.movie;
}


@end
