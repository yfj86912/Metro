//
//  BindEmailViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/5/14.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "BindEmailViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface BindEmailViewController ()

@end

@implementation BindEmailViewController
@synthesize textFieldForCheckNumber, textFieldForEmail, btnForCheckNumber, btnForBind;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    textFieldForCheckNumber.returnKeyType = UIReturnKeyDone;
    textFieldForEmail.returnKeyType = UIReturnKeyDone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [MBProgressHUD hideHUDForView:self.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)comeback:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)bindEmail:(id)sender {
    if ([textFieldForEmail.text isEqual:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入邮箱" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([textFieldForCheckNumber.text isEqual:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入验证码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    btnForBind.enabled = NO;
    
    [MBProgressHUD showMessage:nil toView:self.view];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, login];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 501;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BindEmail_Check\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"Code\":\"%@\",", textFieldForCheckNumber.text];
    NSString *str4 = [NSString stringWithFormat:@"\"Email\":\"%@\"}", textFieldForEmail.text];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (IBAction)actionForCheckNumber:(id)sender {
    if ([textFieldForEmail.text isEqual:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入邮箱" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    btnForCheckNumber.enabled = NO;
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, login];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 500;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BindEmail_ValidateCode\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"FullName\":\"%@\",", [d objectForKey:@"FullName"]];
    NSString *str4 = [NSString stringWithFormat:@"\"Email\":\"%@\"}", textFieldForEmail.text];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 500)
    {
        btnForCheckNumber.enabled = YES;
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:@"验证码已发到邮箱，请注意查收！"];
            
        }
        else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
    else if (_request.tag ==501)
    {
        btnForBind.enabled = YES;
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:@"绑定邮箱成功！"];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    btnForCheckNumber.enabled = YES;
    btnForBind.enabled = YES;
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"绑定邮箱失败, 请检查网络！"];
}


@end
