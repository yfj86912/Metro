//
//  MyMeetingViewController.h
//  shanghaiditie
//
//  Created by yfj on 15/6/1.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMeetingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewForMeeting;
- (IBAction)comeBack:(id)sender;
@end
