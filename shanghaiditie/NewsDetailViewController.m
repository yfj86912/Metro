//
//  NewsDetailViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/10.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "Mycrypt.h"

@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController
@synthesize dicForNews;
@synthesize labelForTime, labelForTitle;
@synthesize strForNewsId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    [self.view addSubview:webView];
    
    [self getNews];
    
}

////新闻阅读
- (void)getNews
{
    if (!strForNewsId) {
        strForNewsId = [NSString stringWithFormat:@"%@", [dicForNews objectForKey:@"NewsId"]];
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
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"KYFW_NewsInfo_ById\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"NewsId\":\"%@\"}",strForNewsId];
    
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
            dicForNewsDetail = [[NSDictionary alloc]initWithDictionary:[result objectForKey:@"Message"]];
            NSString * contentStr = [Mycrypt decryptWithText:[dicForNewsDetail objectForKey:@"Content"]] ;
            
            [webView loadHTMLString:contentStr baseURL:nil];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    
}

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
