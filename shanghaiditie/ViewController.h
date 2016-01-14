//
//  ViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/1.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    NSMutableArray * arrayForFoundtion;
    NSMutableArray * arrayForMessageCount;
    NSMutableArray * arrayForIcons;
    
    UIButton * btnforbackground;
    UIView * viewForPersonInfo;
    UILabel * labelForname;
    UILabel * labelForCompany;
    UILabel * labelForSection;
    UILabel * labelForPost;
    
    NSDictionary * dicForVersion;
}

@property (weak, nonatomic) IBOutlet UIButton *btnForHeadImage;

- (IBAction)relogin:(id)sender;
- (IBAction)actionForServiceNews:(id)sender;
- (IBAction)actionForSalary:(id)sender;
- (IBAction)actionForDang:(id)sender;
- (IBAction)actionForJian:(id)sender;
- (IBAction)actionForGong:(id)sender;
- (IBAction)actionForTuan:(id)sender;
- (IBAction)actionForZong:(id)sender;
- (IBAction)actionForZhu:(id)sender;
- (IBAction)actionForDangBan:(id)sender;
- (IBAction)actionForCheng:(id)sender;
- (IBAction)actionForZhi:(id)sender;
- (IBAction)actionForShe:(id)sender;
- (IBAction)actionFor2:(id)sender;
- (IBAction)actionFor11:(id)sender;
- (IBAction)actionFor13:(id)sender;
- (IBAction)actionFor17:(id)sender;



@end

