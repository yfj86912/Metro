//
//  ChangeMyPersionInfoViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/5/25.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeMyPersionInfoViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>
{
    UIImage * imageForSend;
    BOOL changeOK;
    UIView * viewForSex;
}

@property (weak, nonatomic) IBOutlet UILabel *labelForName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForHead;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *labelForPart;
@property (weak, nonatomic) IBOutlet UILabel *labelForStation;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForSex;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPhone;
@property (weak, nonatomic) IBOutlet UILabel *LabelForEmail;
@property (weak, nonatomic) IBOutlet UITextView *textViewFordes;
@property (weak, nonatomic) IBOutlet UIButton *btnForChangeimageHead;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForChangeHead;
@property (weak, nonatomic) IBOutlet UIButton *btnForSave;

@property (weak, nonatomic) IBOutlet UIButton *btnFortextViewOK;
- (IBAction)actionForHideKeyboard:(id)sender;

- (IBAction)actionForChangeHead:(id)sender;
- (IBAction)actionForSave:(id)sender;
- (IBAction)comeback:(id)sender;

@end
