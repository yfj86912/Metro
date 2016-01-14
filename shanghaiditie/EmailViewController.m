//
//  EmailViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/8.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "EmailViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"


@interface EmailViewController ()

@end

@implementation EmailViewController
@synthesize textFieldForUserName;
@synthesize checkViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    textFieldForUserName.returnKeyType = UIReturnKeyDone;
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

- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextAction:(id)sender {
    [MBProgressHUD showMessage:@"正在请求验证码..." toView:self.view];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, login];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 301;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"PasswordRecovery\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginName\":\"%@\"}", textFieldForUserName.text];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
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
    if(_request.tag == 301)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            NSLog(@"get checkNumber succeed!!!");
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            [d setObject:textFieldForUserName.text forKey:@"username"];
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:@"验证码已经发到邮箱，请注意查收！"];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            checkViewController = [storyboard instantiateViewControllerWithIdentifier:@"checkViewController"];
            //    checkViewController.stringForEmail = textFieldForEmail.text;
            [self.navigationController pushViewController:checkViewController animated:YES];
        }else {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"请求验证码失败，请检查网络！"];
}

@end
