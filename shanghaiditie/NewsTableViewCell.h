//
//  NewsTableViewCell.h
//  shanghaiditie
//
//  Created by 21k on 15/4/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewForNews;
@property (weak, nonatomic) IBOutlet UILabel *labelForNewsTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForNewsContent;
@end
