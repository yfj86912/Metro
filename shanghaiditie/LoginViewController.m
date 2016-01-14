//
//  LoginViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/7.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize textFieldForPassword, textFieldForUserName;
@synthesize emailViewController;
@synthesize imageViewForbackground;
@synthesize btnForGT;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([UIScreen mainScreen].bounds.size.height==480 && [UIScreen mainScreen].bounds.size.width==320) {
        imageViewForbackground.image = [UIImage imageNamed:@"login640_960"];
    }else if([UIScreen mainScreen].bounds.size.height>500 && [UIScreen mainScreen].bounds.size.width==320){
        imageViewForbackground.image = [UIImage imageNamed:@"login640_1136"];
    }else if ([UIScreen mainScreen].bounds.size.width==375)
    {
        imageViewForbackground.image = [UIImage imageNamed:@"login750"];
    }else if([UIScreen mainScreen].bounds.size.width==540)
    {
        imageViewForbackground.image = [UIImage imageNamed:@"login1080"];
    }
    
    textFieldForUserName.delegate = self;
    textFieldForUserName.returnKeyType = UIReturnKeyDone;
    textFieldForPassword.delegate = self;
    textFieldForUserName.returnKeyType = UIReturnKeyDone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPasswordSucceed) name:@"getPasswordSucceed" object:nil];
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
- (IBAction)loginAction:(id)sender {
    if ([textFieldForUserName.text isEqual:@""]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入账号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([textFieldForPassword.text isEqual:@""]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString * strForuserName;
    if ([textFieldForUserName.text isEqual:@"admin"]) {
        strForuserName = textFieldForUserName.text;
    }else{
        strForuserName = [NSString stringWithFormat:@"%@%@",btnForGT.titleLabel.text, textFieldForUserName.text];
    }
    [MBProgressHUD showMessage:@"正在登录..." toView:self.view];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, login];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 300;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"Login\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginName\":\"%@\",", strForuserName];
    NSString *str3 = [NSString stringWithFormat:@"\"ClientID\":\"%@\",", @"123456789"];
    NSString *str4 = [NSString stringWithFormat:@"\"Password\":\"%@\"}", textFieldForPassword.text];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textFieldForPassword resignFirstResponder];
    [textFieldForUserName resignFirstResponder];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == textFieldForPassword.tag) {
        self.view.frame = CGRectMake(0, -30, self.view.frame.size.width, self.view.frame.size.height);
    }
}

-(void)getPasswordSucceed
{
    [emailViewController.checkViewController.navigationController popToViewController:self animated:YES];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 300)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            NSLog(@"Login succeed!!!");
            [MBProgressHUD hideHUDForView:self.view];
//            [MBProgressHUD showSuccess:@"登录成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSendDeviceToken" object:nil];
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            NSDictionary * dicForUserInfo = [result objectForKey:@"Message"];
            
            NSString * strForuserName;
            if ([textFieldForUserName.text isEqual:@"admin"]) {
                strForuserName = textFieldForUserName.text;
            }else{
                strForuserName = [NSString stringWithFormat:@"%@%@",btnForGT.titleLabel.text, textFieldForUserName.text];
            }
            
            [d setObject:strForuserName forKey:@"username"];
            [d setObject:textFieldForPassword.text forKey:@"password"];
            
            [d setObject:[dicForUserInfo objectForKey:@"LoginImgUrl"] forKey:@"LoginImgUrl"];
            [d setObject:[dicForUserInfo objectForKey:@"CompanyName"] forKey:@"CompanyName"];
            [d setObject:[dicForUserInfo objectForKey:@"Signature"] forKey:@"Signature"];
            [d setObject:[dicForUserInfo objectForKey:@"FullName"] forKey:@"FullName"];
            [d setObject:[dicForUserInfo objectForKey:@"LoginId"] forKey:@"LoginId"];
            [d setObject:[dicForUserInfo objectForKey:@"CompanyId"] forKey:@"CompanyId"];
            [d setObject:[dicForUserInfo objectForKey:@"DepartmentName"] forKey:@"DepartmentName"];
            [d setObject:[dicForUserInfo objectForKey:@"PostName"] forKey:@"PostName"];
            [d setObject:[dicForUserInfo objectForKey:@"DepartmentId"] forKey:@"DepartmentId"];
            [d setObject:[dicForUserInfo objectForKey:@"Email"] forKey:@"Email"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginOk" object:nil];
            if (![dicForUserInfo objectForKey:@"Email"] || [[dicForUserInfo objectForKey:@"Email"] isEqualToString:@""]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                bindEmailViewController = [storyboard instantiateViewControllerWithIdentifier:@"BindEmailViewController"];
                [self.navigationController pushViewController:bindEmailViewController animated:YES];
                
            }else{
                [self.navigationController popViewControllerAnimated:NO];
            }
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
    [MBProgressHUD showError:@"登录失败 ，请检查网络！"];
}


- (IBAction)Forget:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    emailViewController = [storyboard instantiateViewControllerWithIdentifier:@"emailViewController"];
    [self.navigationController pushViewController:emailViewController animated:YES];

}

- (IBAction)actionForChangeGT:(id)sender {
    if ([btnForGT.titleLabel.text isEqual:@"G"]) {
        [btnForGT setTitle:@"T" forState:UIControlStateNormal];
    }else{
        [btnForGT setTitle:@"G" forState:UIControlStateNormal];
    }
}


@end
