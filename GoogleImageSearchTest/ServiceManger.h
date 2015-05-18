//
//  ServiceManger.h
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SearchCompletion)(NSArray *imageResults, NSError *error);

@class ImageSearchRequest;
@interface ServiceManger : NSObject

+ (instancetype)sharedManger;

- (void)startReachabilityMonitoring;
- (void)stopReachabilityMonitoring;

- (void)searchImagesWithRequest:(ImageSearchRequest *)request completion:(SearchCompletion)completion;
- (void)loadMoreImages;


@end
