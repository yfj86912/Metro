//
//  MeetingReserveViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingReserveViewController : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *meetingName;
@property (weak, nonatomic) IBOutlet UITextField *meetinfhold;
@property (weak, nonatomic) IBOutlet UITextField *meetingStart;
@property (weak, nonatomic) IBOutlet UITextField *meetingEnd;

- (IBAction)comeback:(id)sender;
- (IBAction)nextAction:(id)sender;
@end
