//
//  ChangePasswordViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/5/28.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *mynewPassword;
@property (weak, nonatomic) IBOutlet UITextField *mynewPasswordOK;

- (IBAction)comeback:(id)sender;
- (IBAction)uploadPassword:(id)sender;
@end
