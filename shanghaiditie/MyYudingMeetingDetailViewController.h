//
//  MyYudingMeetingDetailViewController.h
//  shanghaiditie
//
//  Created by yfj on 15/6/8.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyYudingMeetingDetailViewController : UIViewController
{
}
@property (weak, nonatomic) IBOutlet UILabel *labelForMeetingName;
@property (weak, nonatomic) IBOutlet UIView *viewForDetail;
@property (weak, nonatomic) IBOutlet UILabel *labelForAudit;
@property (weak, nonatomic) IBOutlet UILabel *labelForholdName;
@property (weak, nonatomic) IBOutlet UILabel *labelForStartTime;
@property (weak, nonatomic) IBOutlet UILabel *labelForEndTime;
@property (weak, nonatomic) IBOutlet UILabel *labelForAddress;

@property (nonatomic, strong) NSString *strForMeetingId;
@property (nonatomic, strong) NSDictionary * dicForMeetingInfo;

- (IBAction)comeback:(id)sender;
@end
