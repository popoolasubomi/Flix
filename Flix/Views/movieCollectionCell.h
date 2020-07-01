//
//  movieCollectionCell.h
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 6/24/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface MovieCollectionCell : UICollectionViewCell

@property (nonatomic, strong) Movie *movie;

@property (weak, nonatomic) IBOutlet UIImageView *posterView;

- (void)setMovie:(Movie *)movie;

@end

NS_ASSUME_NONNULL_END
