//
//  ImageQuery.m
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import "ImageSearchRequest.h"

// These constraints are defined by Google
#define MaximumPageSize         8
#define MaximumPagesAllowed     8

@implementation ImageSearchRequest

- (instancetype)initWithQuery:(NSString *)query {
    self = [super init];
    if (self) {
        self.query = query;
        self.size = MaximumPageSize;
        self.offset = 0;
    }
    return self;
}
+ (instancetype)defaultRequestWithQuery:(NSString *)query {
    ImageSearchRequest *request = [[ImageSearchRequest alloc] initWithQuery:query];
    return request;
}

- (NSDictionary *)requestParameters {
    return @{@"v": @"1.0",
             @"q": self.query,
             @"rsz": @(self.size),
             @"start": @(self.offset)};
}

- (instancetype)nextPageRequest {
    ImageSearchRequest *newRequest = [self copy];
    newRequest.offset = self.offset + self.size;
    return newRequest;
}

- (id)copyWithZone:(NSZone *)zone {
    ImageSearchRequest *newRequest = [[[self class] alloc] init];
    newRequest.query = [self.query copyWithZone:zone];
    newRequest.size = self.size;
    newRequest.offset = self.offset;
    return newRequest;
}

@end
