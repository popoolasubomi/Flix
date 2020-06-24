//
//  moviesGridViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "moviesGridViewController.h"
#import "movieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "detailsViewController.h"

@interface moviesGridViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property(nonatomic, strong) NSMutableArray *fullMovies;
@property(nonatomic, strong) NSMutableArray *data;
@property(nonatomic, strong) NSArray *filteredData;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation moviesGridViewController

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
               self.fullMovies = dataDictionary[@"results"];
               self.data = [NSMutableArray new];
               
               for (NSDictionary *movie in self.movies){
                   NSString *info = movie[@"title"];
                   [self.data addObject: info];
               }

               [self.collectionView reloadData];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    movieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"MovieCollectionCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.item];
    NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
    if ([movie[@"poster_path"] isKindOfClass:[NSString class]]) {
        NSString *posterUrlString =  movie[@"poster_path"];
        NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat:posterUrlString];
        NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
        cell.posterView.image = nil;
        [cell.posterView setImageWithURL: posterUrl];
    }else{
        cell.posterView.image = nil;
}
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length != 0){
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject containsString:searchText];
        }];
        self.filteredData = [self.data filteredArrayUsingPredicate:predicate];
        NSMutableArray *dummy_array = [NSMutableArray new];
        for (NSDictionary *movie in self.fullMovies){
            NSString *movie_data = movie[@"title"];
            if ([self.filteredData containsObject: movie_data]){
                [dummy_array addObject: movie];
            }
        }
        self.movies = dummy_array;
    }
    else{
        self.movies = self.fullMovies;
    }
    [self.collectionView reloadData];
}

- (IBAction)onSwipeDownActivity:(id)sender {
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
          UITableViewCell *tappedCell = sender;
          NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
          NSDictionary *movie = self.movies[indexPath.row];
          
          detailsViewController *DetailsViewController = [segue destinationViewController];
          DetailsViewController.movie = movie;
}

@end
