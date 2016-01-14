//
//  MeetingReserveStepTwoViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingReserveStepTwoViewController : UIViewController


@property (nonatomic, strong) NSString * strForMeetingName;
@property (nonatomic, strong) NSString * strForMeetingHost;
@property (nonatomic, strong) NSString * strForBeginDate;
@property (nonatomic, strong) NSString * strForEndDate;

- (IBAction)comeback:(id)sender;
- (IBAction)refreshAction:(id)sender;
@end
