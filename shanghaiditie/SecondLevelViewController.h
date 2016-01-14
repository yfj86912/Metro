//
//  SecondLevelViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/15.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondLevelViewController : UIViewController
{
    NSArray * arrayForChildFoundtion;
    NSMutableArray * arrayForIcons;
}

@property (nonatomic, strong) NSDictionary * DicForFoundtion;
@property (nonatomic) NSInteger typeNumber;
@property (nonatomic, strong) NSDictionary * dicForNews;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (nonatomic, strong) NSString * FirstdepartmentId;
@property (nonatomic, strong) NSMutableArray * arrayForChildrenMessageCount;

-(void)getIcons;

- (IBAction)comeback:(id)sender;
@end
