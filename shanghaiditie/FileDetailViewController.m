//
//  FileDetailViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/11.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "FileDetailViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "Mycrypt.h"

@interface FileDetailViewController ()<UIWebViewDelegate>
{
    UIWebView *webView;
    NSString *url;
    BOOL isback;
}


@property (nonatomic) BOOL ishide;
- (IBAction)comeback:(id)sender;

@end

@implementation FileDetailViewController

@synthesize url;
@synthesize ishide;
@synthesize strForFileId;
@synthesize dicForFile;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    webView.delegate = self;
    //    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0]];
    [self.view addSubview:webView];
    isback = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (ishide) {
//        self.navigationController.navigationBarHidden = YES;
//    }else{
//        self.navigationController.navigationBarHidden = NO;
//    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


////新闻阅读
- (void)getNews
{
    if (!strForFileId) {
        strForFileId = [NSString stringWithFormat:@"%@", [dicForFile objectForKey:@"Id"]];
    }
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url1=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url1];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 501;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_WJ_FileInfo\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"WJBasicId\":\"%@\"}",strForFileId];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 501)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            dicForFileDetail = [[NSDictionary alloc]initWithDictionary:[result objectForKey:@"Message"]];
            NSString * contentStr = [Mycrypt decryptWithText:[dicForFileDetail objectForKey:@"FileContent"]] ;
            
            [webView loadHTMLString:contentStr baseURL:nil];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    
}



//modified 3.5
- (int) dataNetworkTypeFromStatusBar {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"]    subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    int tempNum = [[dataNetworkItemView valueForKey:@"dataNetworkType"] intValue];
    if (tempNum==1) {
        return 1;//2g
    }else if (tempNum==2){
        return 2;
    }else if (tempNum==3){
        return 3;
    }else if (tempNum==5){
        return 4;
    }else
        return 0;
}


//  webviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * rurl = [[request URL]absoluteString];
    if ([rurl isEqual:@"http://finishwebview/"]) {
        [self back];
    }
    //    if ([rurl hasPrefix:@"protocol://"]) {
    //        [self back];
    //    }
    return YES;
}

//开启
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    
}

//完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (isback) {
        return;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"网络错误！" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self back];
}

-(void)back
{
    //    if ([webView canGoBack]) {
    //        [webView goBack];
    //    }
    //    else{
    isback = YES;
    [self.navigationController popViewControllerAnimated:YES];
    //    }
}

- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
