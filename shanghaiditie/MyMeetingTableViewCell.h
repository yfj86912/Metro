//
//  MyMeetingTableViewCell.h
//  shanghaiditie
//
//  Created by 21k on 15/6/2.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMeetingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelForMeetingName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForPic;
@property (weak, nonatomic) IBOutlet UILabel *labelForMeetingTime;
@property (weak, nonatomic) IBOutlet UILabel *labelForStatu;
@end
