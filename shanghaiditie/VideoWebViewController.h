//
//  VideoWebViewController.h
//  shanghaiditie
//
//  Created by yfj on 15/8/5.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoWebViewController : UIViewController
{
    UIWebView *mywebView;
    NSString *url;
}
@property (nonatomic) int witchWebview;

- (IBAction)comeback:(id)sender;
@end
