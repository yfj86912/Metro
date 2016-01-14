//
//  ShowMessageNumberButton.h
//  shanghaiditie
//
//  Created by 21k on 15/6/4.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowMessageNumberButton : UIButton

@property (nonatomic, strong)  UIImageView * imageViewForMessageBackground;
@property (nonatomic, strong) UILabel * labelForNumber;

-(void)addMessageNumber;

@end
