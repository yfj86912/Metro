//
//  EmailViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/8.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckViewController.h"

@interface EmailViewController : UIViewController
{
    CheckViewController *checkViewController;
}

@property (nonatomic, strong) CheckViewController *checkViewController;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForUserName;

- (IBAction)comeback:(id)sender;
- (IBAction)nextAction:(id)sender;
@end
