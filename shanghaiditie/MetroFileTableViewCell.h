//
//  MetroFileTableViewCell.h
//  shanghaiditie
//
//  Created by winter on 16/2/3.
//  Copyright © 2016年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetroFileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelForfileName;
@property (weak, nonatomic) IBOutlet UILabel *labelForFileZhuanYe;
@property (weak, nonatomic) IBOutlet UILabel *labelForFileGangWei;
@property (nonatomic, strong) NSString * strForFileUrl;

@end
