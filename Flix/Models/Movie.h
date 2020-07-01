//
//  Movie.h
//  Flix
//
//  Created by Ogo-Oluwasobomi Popoola on 7/1/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Movie : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *posterUrlString;
@property (nonatomic, strong) NSString *backdropPath;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *id_str;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
