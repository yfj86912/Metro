//
//  MeetingReserveStepThridViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/10.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingReserveStepThridViewController : UIViewController

@property (nonatomic, strong) NSString * strForMeetingName;
@property (nonatomic, strong) NSString * strForMeetingHost;
@property (nonatomic, strong) NSDictionary * dicForMeetingPlace;
@property (nonatomic, strong) NSString * strForBeginDate;
@property (nonatomic, strong) NSString * strForEndDate;

- (IBAction)comeback:(id)sender;
@end
