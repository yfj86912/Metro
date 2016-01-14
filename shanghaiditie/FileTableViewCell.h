//
//  FileTableViewCell.h
//  shanghaiditie
//
//  Created by 21k on 15/6/11.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *labelForFileKind;
@property (weak, nonatomic) IBOutlet UILabel *labelForFileTime;

@end
