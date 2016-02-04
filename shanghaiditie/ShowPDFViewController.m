//
//  ShowPDFViewController.m
//  shanghaiditie
//
//  Created by winter on 16/2/4.
//  Copyright © 2016年 21k. All rights reserved.
//

#import "ShowPDFViewController.h"

@interface ShowPDFViewController ()

@end

@implementation ShowPDFViewController
@synthesize url;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    [self.view addSubview:webView];
    NSURL *urlR=[NSURL URLWithString:url];
    NSURLRequest *request=[NSURLRequest requestWithURL:urlR];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//  webviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


-(void)back
{
    if ([webView canGoBack]) {
        [webView goBack];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
