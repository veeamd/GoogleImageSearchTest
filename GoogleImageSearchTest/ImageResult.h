//
//  ImageResult.h
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageResult : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *tbURL;
@property (nonatomic) NSInteger tbWidth;
@property (nonatomic) NSInteger tbHeight;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)objectFromDictionary:(NSDictionary *)dict;

@end
