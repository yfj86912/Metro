//
//  FeedBackViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/5/25.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "FeedBackViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface FeedBackViewController ()<UIAlertViewDelegate>

@end

@implementation FeedBackViewController
@synthesize textViewForSay;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    textViewForSay.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"感谢您提的宝贵意见"])
    {
        textView.text = @"";
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionForUpload:(id)sender {
    [MBProgressHUD showMessage:@"正在提交..." toView:self.view];
    NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    NSString * currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 901;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_FeedBack\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"UserName\":\"%@\",", [d objectForKey:@"FullName"]];
    NSString *str4 = [NSString stringWithFormat:@"\"DepartmentName\":\"%@\",", [d objectForKey:@"DepartmentName"]];
    NSString *str5 = [NSString stringWithFormat:@"\"CompanyName\":\"%@\",", [d objectForKey:@"CompanyName"]];
    NSString *str6 = [NSString stringWithFormat:@"\"TypeName\":\"IOS\","];
    NSString *str7 = [NSString stringWithFormat:@"\"VersionNote\":\"%@\",", currentVersion];
    NSString *str8 = [NSString stringWithFormat:@"\"Note\":\"%@\"}", textViewForSay.text];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str6 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str7 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str8 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (IBAction)comebackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 901)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:[result objectForKey:@"Message"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"提交失败，请检查网络！"];
}

@end
