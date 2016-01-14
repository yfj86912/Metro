//
//  ServiceNewsViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServiceNewsViewControllerDelegate <NSObject>

-(void)showReadNumber:(int)Number tag:(int)tagNum;

@end

@interface ServiceNewsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * arrayForNews;
    NSMutableArray * arrayForImages;
    
    int pageIndex;
    int totalPageNumber;
    int listNumber;
    //下拉刷新相关控件
    UILabel * refreshLabel1;
    UIImageView * refreshImage1;
    UIActivityIndicatorView * refreshSpinner1;    ///滑动刷新
    UIView * refreshFooterView1;
    
    int readNumber;
}

@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForNews;
@property (nonatomic, strong) NSString * strFortitle;
@property (nonatomic, strong) NSString * FirstdepartmentId;
@property (nonatomic)  int tagNumber;
@property (weak, nonatomic) id<ServiceNewsViewControllerDelegate> delegate;

- (IBAction)comeback:(id)sender;


@end
