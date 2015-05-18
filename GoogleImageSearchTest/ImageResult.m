//
//  ImageResult.m
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import "ImageResult.h"

@implementation ImageResult

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (dict) {
        self.title = dict[@"contentNoFormatting"];
        self.URL = [NSURL URLWithString:dict[@"url"]];
        self.width = [dict[@"width"] integerValue];
        self.height = [dict[@"height"] integerValue];
        self.tbURL = [NSURL URLWithString:dict[@"tbUrl"]];
        self.tbWidth = [dict[@"tbHeight"] integerValue];
        self.tbHeight = [dict[@"tbHeight"] integerValue];
    }
    return self;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict {
    ImageResult *imageResult = [[[self class] alloc] initWithDictionary:dict];
    return imageResult;
}

@end
