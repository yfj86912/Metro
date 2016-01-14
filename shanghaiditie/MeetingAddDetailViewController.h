//
//  MeetingAddDetailViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/5.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingAddDetailViewController : UIViewController
{
    NSMutableArray * arrFormeeting;
}

@property (nonatomic, strong) NSMutableDictionary * dicForAddressInfo;

@property (weak, nonatomic) IBOutlet UILabel *labelForAddressName;
@property (weak, nonatomic) IBOutlet UILabel *labelForAddressNote;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForMeeting;

- (IBAction)comeback:(id)sender;

@end
