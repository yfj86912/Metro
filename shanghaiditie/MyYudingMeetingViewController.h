//
//  MyYudingMeetingViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/2.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyYudingMeetingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewForMeeting;
- (IBAction)comeback:(id)sender;
@end
