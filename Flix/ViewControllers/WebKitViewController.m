//
//  WebKitViewController.m
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "WebKitViewController.h"

@interface WebKitViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSDictionary *youtubeData;

@end

@implementation WebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self playVideo];
    
}

-(void) playVideo{
    
    NSString *id = [NSString stringWithFormat:@"%@", self.movie[@"id"]];
    NSString *urlString = [NSString stringWithFormat: @"https://api.themoviedb.org/3/movie/%@/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed", id];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                            timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               if (error != nil) {
                   NSLog(@"%@", [error localizedDescription]);
               }
               else {
                   NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                   self.youtubeData = dataDictionary;
                   NSArray *results = self.youtubeData[@"results"];
                   NSDictionary *result = results[0];
                   NSString *youtubeLink = [NSString stringWithFormat: @"https://www.youtube.com/watch?v=%@", result[@"key"]];
                   NSURL *youtubeUrl = [NSURL URLWithString:youtubeLink];
                   NSURLRequest *youtubeRequest = [NSURLRequest requestWithURL: youtubeUrl
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                         timeoutInterval:10.0];
                   [self.webView loadRequest: youtubeRequest];
               }
           }];
        [task resume];
    
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
