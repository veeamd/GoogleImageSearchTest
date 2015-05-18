//
//  ServiceManger.m
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import "ServiceManger.h"
#import "AFNetworking.h"
#import "ImageResult.h"
#import "ImageSearchRequest.h"

@interface ServiceManger()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) ImageSearchRequest *currentRequest;
@property (nonatomic, strong) SearchCompletion completionBlock;

@end

NSString *const baseURLStr = @"https://ajax.googleapis.com/ajax/services/";

@implementation ServiceManger

+ (instancetype)sharedManger {
    static dispatch_once_t once;
    static ServiceManger *shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
        NSURL *baseURL = [NSURL URLWithString:baseURLStr];
        AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        sessionManager.requestSerializer.timeoutInterval = 10;
        sessionManager.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:@"ajax.googleapis.com"];
        shared.sessionManager = sessionManager;
    });
    
    return shared;
}

- (void)startReachabilityMonitoring {
    [self.sessionManager.reachabilityManager startMonitoring];
}

- (void)stopReachabilityMonitoring {
    [self.sessionManager.reachabilityManager stopMonitoring];
}

- (void)searchImagesWithRequest:(ImageSearchRequest *)request completion:(SearchCompletion)completion {
    self.currentRequest = request;
    self.completionBlock = completion;
    [self.sessionManager GET:@"search/images"
                  parameters:[request requestParameters]
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSDictionary *responseDict = responseObject;
                         NSArray *imageResults = [self getImageResultsFromResponse:responseDict];
                         if (imageResults) {
                             self.completionBlock(imageResults, nil);
                         } else {
                             NSError *error = [self getErrorFromResponse:responseDict];
                             self.completionBlock(nil, error);
                         }
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         self.completionBlock(nil, error);
                     }];
}

- (void)loadMoreImages {
    ImageSearchRequest *newRequest = [self.currentRequest nextPageRequest];
    [self searchImagesWithRequest:newRequest completion:self.completionBlock];
}

#pragma mark - Internal Methods
- (NSArray *)getImageResultsFromResponse:(NSDictionary *)response {
    if ([response[@"responseStatus"] integerValue] != 200) {
        return nil;
    } else {
        NSDictionary *responseData = response[@"responseData"];
        NSArray *results = responseData[@"results"];
        NSMutableArray *resultImageArr = [NSMutableArray array];
        for (NSDictionary *resultInfo in results) {
            ImageResult *imageResult = [ImageResult objectFromDictionary:resultInfo];
            [resultImageArr addObject:imageResult];
        }
        return [resultImageArr copy];
    }
}

- (NSError *)getErrorFromResponse:(NSDictionary *)response {
    NSString *errorDetail = response[@"responseDetails"];
    NSInteger errorCode = [response[@"responseStatus"] integerValue];
    NSError *error = [NSError errorWithDomain:@"ServiceManager"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorDetail ? errorDetail : @""}];
    return error;
}

@end
