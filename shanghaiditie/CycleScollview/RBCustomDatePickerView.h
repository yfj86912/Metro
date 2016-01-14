//
//  RBCustomDatePickerView.h
//  RBCustomDateTimePicker
//  e-mail:rbyyy924805@163.com
//  Created by renbing on 3/17/14.
//  Copyright (c) 2014 renbing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXSCycleScrollView.h"

@protocol RBCustomDatePickerViewDelegate <NSObject>

-(void)chooseTimeStr:(NSString *)strForTime;

@end

@interface RBCustomDatePickerView : UIView <MXSCycleScrollViewDatasource,MXSCycleScrollViewDelegate>


@property (nonatomic, strong) NSString * strForChooseTime;
@property (nonatomic, weak) id<RBCustomDatePickerViewDelegate> delegate;

@end
