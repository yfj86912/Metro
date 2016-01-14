//
//  NewsDetailViewController.h
//  shanghaiditie
//
//  Created by 21k on 15/4/10.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDetailViewController : UIViewController<UIWebViewDelegate>
{
    NSDictionary * dicForNewsDetail;
    UIWebView *webView;
}

@property(nonatomic, strong) NSString * strForNewsId;
@property(nonatomic, strong) NSDictionary *dicForNews;
@property (nonatomic, strong) NSString * url;
- (IBAction)comeback:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForTime;
@end
