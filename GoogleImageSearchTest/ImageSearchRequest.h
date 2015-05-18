//
//  ImageQuery.h
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSearchRequest : NSObject <NSCopying>

@property (nonatomic, strong) NSString *query;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger offset;

- (instancetype)initWithQuery:(NSString *)query;
+ (instancetype)defaultRequestWithQuery:(NSString *)query;
- (NSDictionary *)requestParameters;
- (instancetype)nextPageRequest;


@end
