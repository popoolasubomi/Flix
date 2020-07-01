//
//  moviesViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "MoviesViewController.h"
#import "movieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "Reachability.h"
#import "OAPMovieFetcher.h"
#import "Movie.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MoviesViewController

@synthesize internetActive;
@synthesize hostActive;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setReachabilityNotifier];
    
    [self.activityIndicator startAnimating];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.alpha = 0;
    
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.tableView addSubview:self.refreshControl];
    
    [self fetchMovies];
    
    [NSTimer scheduledTimerWithTimeInterval:1.50f target:self selector:@selector(revealData) userInfo:nil repeats:NO];
}


-(void) fetchMovies{
    OAPMovieFetcher *oapMovieFetcher = [OAPMovieFetcher sharedObject];
    [oapMovieFetcher fetchMoviesWithCompletionHandler:^(NSArray *movies) {
        NSArray *dictionaries = movies;
        self.movies = [NSMutableArray new];
        for (NSDictionary *dictionary in dictionaries) {
            Movie *movie =  [[Movie alloc] initWithDictionary: dictionary];
            [self.movies addObject: movie];
        }
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

-(void) customizeNavigationBar{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"codePathLogo"] forBarMetrics:UIBarMetricsDefault];
    navigationBar.tintColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:0.8];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    shadow.shadowOffset = CGSizeMake(2, 2);
    shadow.shadowBlurRadius = 4;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:22],
                                          NSForegroundColorAttributeName : [UIColor colorWithRed:0.5 green:0.15 blue:0.15 alpha:0.8],
                                          NSShadowAttributeName : shadow};
}

-(void)revealData{
    self.tableView.alpha = 1;
    [self.activityIndicator stopAnimating];
}

-(void) setReachabilityNotifier{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];

    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReachable startNotifier];
}

-(void)noConnection{
       if (self.internetActive == NO ) {
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                  message:@"The internet connection appears to be offline"
                  preferredStyle:(UIAlertControllerStyleAlert)];
           
           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * _Nonnull action) {
                                      [self setReachabilityNotifier];}];
           [alert addAction:okAction];
           
           [self presentViewController:alert animated:YES completion:^{
           }];
       }
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            self.internetActive = NO;
            [self noConnection];
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            break;
        }
    }

    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)

            {
            case NotReachable:
        {
            self.hostActive = NO;
            break;
            }
            case ReachableViaWiFi:
            {
            self.hostActive = YES;
            break;

    }
    case ReachableViaWWAN:
    {
        self.hostActive = YES;
        break;
    }
}
    [internetReachable stopNotifier];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    Movie *movie = self.movies[indexPath.row];
    [cell setMovie: movie];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
       UITableViewCell *tappedCell = sender;
       NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
       NSDictionary *movie = self.movies[indexPath.row];
       
       DetailsViewController *detailsViewController = [segue destinationViewController];
       detailsViewController.movie = movie;
}


@end
