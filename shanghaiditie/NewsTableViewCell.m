//
//  NewsTableViewCell.m
//  shanghaiditie
//
//  Created by 21k on 15/4/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell
@synthesize labelForNewsContent, labelForNewsTitle, imageViewForNews;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
