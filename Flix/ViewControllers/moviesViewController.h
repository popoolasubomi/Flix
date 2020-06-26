//
//  moviesViewController.h
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Reachability;

@interface MoviesViewController : UIViewController{
    Reachability* internetReachable;
    Reachability* hostReachable;
}

@property BOOL internetActive;
@property BOOL hostActive;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end

NS_ASSUME_NONNULL_END
