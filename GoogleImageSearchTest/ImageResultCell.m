//
//  ImageResultCell.m
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import "ImageResultCell.h"

@interface ImageResultCell ()



@end

@implementation ImageResultCell

- (void)awakeFromNib {
    self.resultImageView.image = [UIImage imageNamed:@"image_placeholder"];
}

- (void)prepareForReuse {
    self.resultImageView.image = [UIImage imageNamed:@"image_placeholder"];
}

@end
