//
//  MeetingDetailViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/4.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingDetailViewController : UIViewController
{
}

@property (weak, nonatomic) IBOutlet UILabel *labelForMeetingName;
@property (weak, nonatomic) IBOutlet UILabel *labelForMeetingCompere;
@property (weak, nonatomic) IBOutlet UILabel *labelForStartTime;
@property (weak, nonatomic) IBOutlet UILabel *labelForEndTime;
@property (weak, nonatomic) IBOutlet UILabel *labelForAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForbackground;

@property (nonatomic, strong) NSString *strForMeetingId;

- (IBAction)comeback:(id)sender;
@end
