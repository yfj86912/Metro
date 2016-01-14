//
//  FeedBackViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/5/25.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedBackViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *comeBack;
@property (weak, nonatomic) IBOutlet UITextView *textViewForSay;
- (IBAction)actionForUpload:(id)sender;
- (IBAction)comebackAction:(id)sender;
@end
