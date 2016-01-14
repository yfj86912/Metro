//
//  LoginViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/7.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailViewController.h"
#import "BindEmailViewController.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{
    EmailViewController *emailViewController;
    BindEmailViewController * bindEmailViewController;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageViewForbackground;
@property (nonatomic, strong) EmailViewController *emailViewController;

@property (weak, nonatomic) IBOutlet UIButton *btnForGT;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForUserName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPassword;
- (IBAction)Forget:(id)sender;
- (IBAction)actionForChangeGT:(id)sender;
@end
