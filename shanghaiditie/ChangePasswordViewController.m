//
//  ChangePasswordViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/5/28.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>

@end

@implementation ChangePasswordViewController
@synthesize oldPassword, mynewPassword, mynewPasswordOK;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    oldPassword.delegate = self;
    oldPassword.tag = 801;
    oldPassword.returnKeyType = UIReturnKeyDone;
    mynewPassword.delegate = self;
    mynewPassword.tag = 802;
    mynewPassword.returnKeyType = UIReturnKeyDone;
    mynewPasswordOK.delegate = self;
    mynewPasswordOK.tag = 803;
    mynewPasswordOK.returnKeyType = UIReturnKeyDone;
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
#pragma mark --键盘遮挡代理
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 802:
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self.view setFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height)];
            }];
        }
            break;
        case 803:
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self.view setFrame:CGRectMake(0, -40, self.view.bounds.size.width, self.view.bounds.size.height)];
            }];
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
    return YES;
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadPassword:(id)sender {
    if ([oldPassword.text isEqual:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入旧密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([mynewPassword.text isEqual:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入新密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([mynewPasswordOK.text isEqual:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请再次输入旧密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![mynewPassword.text isEqual:mynewPasswordOK.text]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"输入两次新密码有误！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在提交..." toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 801;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_Password_Update\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"OldPwd\":\"%@\",", oldPassword.text];
    NSString *str4 = [NSString stringWithFormat:@"\"NewPwdOne\":\"%@\",", mynewPassword.text];
    NSString *str5 = [NSString stringWithFormat:@"\"NewPwdTwo\":\"%@\"}", mynewPasswordOK.text];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
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
    if(_request.tag == 801)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:@"修改密码成功！"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:[result objectForKey:@"Message"]];
}


@end
