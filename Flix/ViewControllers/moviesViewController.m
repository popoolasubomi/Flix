//
//  moviesViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "moviesViewController.h"
#import "movieCell.h"
#import "UIImageView+AFNetworking.h"
#import "detailsViewController.h"
#import "Reachability.h"

@interface moviesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation moviesViewController

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
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
              [self.tableView reloadData];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

-(void)revealData{
    self.tableView.alpha = 1;
    [self.activityIndicator stopAnimating];
}

-(void) setReachabilityNotifier{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];

    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReachable startNotifier];
}

-(void)noConnection{
    //NSLog(@"%@", self.internetActive ? @"YES" : @"NO");
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
               // optional code for what happens after the alert controller has finished presenting
           }];
       }
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            //NSLog(@"The internet is down.");
            self.internetActive = NO;
            [self noConnection];
            break;
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }

    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)

            {
            case NotReachable:
        {
            //NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            break;
            }
            case ReachableViaWiFi:
            {
            //NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            break;

    }
    case ReachableViaWWAN:
    {
        //NSLog(@"A gateway to the host server is working via WWAN.");
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
    movieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.movies[indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseUrlString = @"https://image.tmdb.org/t/p/w500";
    if ([movie[@"poster_path"] isKindOfClass:[NSString class]]) {
        NSString *posterUrlString =  movie[@"poster_path"];
        NSString *fullPosterUrl = [baseUrlString stringByAppendingFormat:posterUrlString];
        NSURL *posterUrl = [NSURL URLWithString:fullPosterUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:posterUrl];
        //[cell.posterView setImageWithURL: posterUrl];
        //__weak MovieCell *weakSelf = self;
        __weak UIImageView *weakImageView = cell.posterView;
        [cell.posterView setImageWithURLRequest:request placeholderImage:nil
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
       UITableViewCell *tappedCell = sender;
       NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
       NSDictionary *movie = self.movies[indexPath.row];
       
       detailsViewController *DetailsViewController = [segue destinationViewController];
       DetailsViewController.movie = movie;
}





@end
