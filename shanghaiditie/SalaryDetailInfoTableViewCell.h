//
//  SalaryDetailInfoTableViewCell.h
//  shanghaiditie
//
//  Created by 21k on 15/4/12.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalaryDetailInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForSalary;
@property (weak, nonatomic) IBOutlet UILabel *labelForTime;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForMonth;

@property (weak, nonatomic) IBOutlet UIButton *btnForLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnForRight;

@end
