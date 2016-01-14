//
//  FileTableViewCell.m
//  shanghaiditie
//
//  Created by 21k on 15/6/11.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "FileTableViewCell.h"

@implementation FileTableViewCell
@synthesize fileName;
@synthesize labelForFileKind, labelForFileTime;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
