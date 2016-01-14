//
//  SalaryInfoViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/12.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalaryInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * arrayForSalary;
    int nowyear;
    int nowmonth;
    int choosemonth;
    BOOL isChange;//////YES 倒序， NO 顺序
}

@property(weak,nonatomic) IBOutlet UITableView * tableViewForSalary;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForHead;
@property (weak, nonatomic) IBOutlet UILabel *labelForUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelForCompany;
@property (weak, nonatomic) IBOutlet UILabel *labelForPart;
@property (weak, nonatomic) IBOutlet UILabel *labelForStation;
@property (nonatomic) int choosemonth;
@property (nonatomic) int chooseYear;

- (IBAction)comeback:(id)sender;
@end
