//
//  moviesGridViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "OAPMovieFetcher.h"

@interface MoviesGridViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property(nonatomic, strong) NSArray *filteredData;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.searchBar.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    [self.collectionView addSubview:self.refreshControl];
    
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;

    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.25;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
   
}

-(void) fetchMovies{
    OAPMovieFetcher *oapMovieFetcher = [OAPMovieFetcher sharedObject];
    [oapMovieFetcher fetchMoviesWithCompletionHandler:^(NSArray *movie) {
        self.movies = movie;
        self.filteredData = self.movies;
        [self.refreshControl endRefreshing];
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"MovieCollectionCell" forIndexPath:indexPath];
    NSDictionary *movie = self.filteredData[indexPath.item];
    NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
    if ([movie[@"poster_path"] isKindOfClass:[NSString class]]) {
        NSString *posterUrlString =  movie[@"poster_path"];
        NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat:posterUrlString];
        NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
        cell.posterView.image = nil;
        NSURLRequest *request = [NSURLRequest requestWithURL:posterUrl];
        __weak UIImageView *weakImageView = cell.posterView;
        [cell.posterView setImageWithURLRequest: request placeholderImage:nil
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
    }else{
        cell.posterView.image = nil;
}
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        if (searchText) {
            if (searchText.length != 0) {
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject[@"title"] containsString:searchText];
                }];
                self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
            }
            else {
                self.filteredData = self.movies;
            }
            NSLog(@"%d", self.filteredData.count);
            [self.collectionView reloadData];
        }
}



- (IBAction)onSwipeDownActivity:(id)sender {
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
          UITableViewCell *tappedCell = sender;
          NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
          NSDictionary *movie = self.filteredData[indexPath.item];
          
          DetailsViewController *detailsViewController = [segue destinationViewController];
          detailsViewController.movie = movie;
}

@end
