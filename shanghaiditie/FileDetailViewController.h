//
//  FileDetailViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/6/11.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileDetailViewController : UIViewController
{
    NSDictionary * dicForFileDetail;
}
@property (nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString * strForFileId;
@property(nonatomic, strong) NSDictionary *dicForFile;
- (IBAction)comeback:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForTime;

@end
