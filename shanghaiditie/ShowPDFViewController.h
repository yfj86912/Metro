//
//  ShowPDFViewController.h
//  shanghaiditie
//
//  Created by winter on 16/2/4.
//  Copyright © 2016年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowPDFViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *webView;
}

@property (nonatomic, strong) NSString * url;
- (IBAction)comeback:(id)sender;

@end
