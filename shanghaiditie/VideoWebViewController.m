//
//  VideoWebViewController.m
//  shanghaiditie
//
//  Created by yfj on 15/8/5.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "VideoWebViewController.h"
#import "NetworkHttpRequest.h"

@interface VideoWebViewController ()<UIWebViewDelegate>
{
    BOOL isAuthed;
    NSURL * currenURL;
    NSURLRequest * originRequest;
}

@end

@implementation VideoWebViewController

@synthesize witchWebview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isAuthed = NO;
    mywebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    mywebView.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString * strForurl;
    switch (witchWebview) {
        case 40:
            strForurl =[NSString stringWithFormat:@"%@/ReceptionShow/FileListHome.aspx?UserId=",server_address];
            break;
        case 41:
            strForurl =[NSString stringWithFormat:@"%@/ReceptionShow/VideoOrFileItemListHome.aspx?UserId=",server_address];
            break;
        case 42:
            strForurl =[NSString stringWithFormat:@"%@/ReceptionShow/ItemHaveDone_List.aspx?UserId=",server_address];
            break;
        default:
            break;
    }
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    url = [NSString stringWithFormat:@"%@%@", strForurl ,[d objectForKey:@"LoginId"]];
    [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0]];
    [self.view addSubview:mywebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  webviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* scheme = [[request URL] scheme];
    NSLog(@"scheme = %@",scheme);
    //判断是不是https
    if ([scheme isEqualToString:@"https"]) {
        //如果是https:的话，那么就用NSURLConnection来重发请求。从而在请求的过程当中吧要请求的URL做信任处理。
        if (!isAuthed) {
            originRequest = request;
            NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
            [mywebView stopLoading];
            return NO;
        }
    }
    
    currenURL = [request URL];
    return YES;
}

#pragma mark - NURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    NSLog(@"WebController Got auth challange via NSURLConnection");
    
    if ([challenge previousFailureCount] == 0)
    {
        isAuthed = YES;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    } else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSLog(@"WebController received response via NSURLConnection");
    
    // remake a webview call now that authentication has passed ok.
    isAuthed = YES;
    [mywebView loadRequest:originRequest];
    
    // Cancel the URL connection otherwise we double up (webview + url connection, same url = no good!)
    [connection cancel];
}

// We use this method is to accept an untrusted site which unfortunately we need to do, as our PVM servers are self signed.
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (IBAction)comeback:(id)sender {
//    if ([webView canGoBack]) {
//        [webView goBack];
//    }
//    else{
        [self.navigationController popViewControllerAnimated:YES];
//    }
}
@end
