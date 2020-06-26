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

    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;

    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.25;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
   
}

-(void) fetchMovies{
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.movies = dataDictionary[@"results"];
               self.filteredData = self.movies;
               [self.collectionView reloadData];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
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
        //[cell.posterView setImageWithURL: posterUrl];
        //__weak MovieCell *weakSelf = self;
        __weak UIImageView *weakImageView = cell.posterView;
        [cell.posterView setImageWithURLRequest: request placeholderImage:nil
        success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
            // imageResponse will be nil if the image is cached
            if (imageResponse) {
                //NSLog(@"Image was NOT cached, fade in image");
                weakImageView.alpha = 0.0;
                weakImageView.image = image;
                
                //Animate UIImageView back to alpha 1 over 0.3sec
                [UIView animateWithDuration:6 animations:^{
                    weakImageView.alpha = 1.0;
                }];
            }
            else {
                //NSLog(@"Image was cached so just update the image");
                weakImageView.image = image;
            }
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
            // do something for the failure condition
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
