//
//  BindEmailViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/5/14.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "ViewController.h"

@interface BindEmailViewController : ViewController
@property (weak, nonatomic) IBOutlet UITextField *textFieldForEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForCheckNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnForCheckNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnForBind;


- (IBAction)comeback:(id)sender;
- (IBAction)bindEmail:(id)sender;
- (IBAction)actionForCheckNumber:(id)sender;
@end
