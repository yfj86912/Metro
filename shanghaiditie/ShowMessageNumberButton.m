//
//  ShowMessageNumberButton.m
//  shanghaiditie
//
//  Created by 21k on 15/6/4.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "ShowMessageNumberButton.h"

@implementation ShowMessageNumberButton
@synthesize imageViewForMessageBackground, labelForNumber;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)addMessageNumber
{
    imageViewForMessageBackground = [[UIImageView alloc]initWithFrame:CGRectMake(40, -10, 20, 20)];
    imageViewForMessageBackground.layer.masksToBounds = YES;
    imageViewForMessageBackground.layer.cornerRadius = 10;
    [imageViewForMessageBackground setBackgroundColor:[UIColor redColor]];
    
    labelForNumber = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    labelForNumber.font = [UIFont systemFontOfSize:12];
    labelForNumber.textColor = [UIColor whiteColor];
    labelForNumber.textAlignment = NSTextAlignmentCenter;
    [imageViewForMessageBackground addSubview:labelForNumber];

    [self addSubview:imageViewForMessageBackground];
}


@end
