//
//  AboutViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/5/29.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
{
    NSMutableArray * versionInforArr;
    int isSelected;
    NSMutableArray * versionNoteArr;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewForversion;
@property (weak, nonatomic) IBOutlet UIButton *comeback;
- (IBAction)comebackAction:(id)sender;
@end
