//
//  CheckViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/8.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textFieldForCheckNumber;
//@property (nonatomic, strong) NSString * stringForEmail;

- (IBAction)comeback:(id)sender;
- (IBAction)checkAction:(id)sender;
@end
