//
//  ViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/1.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "ViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UserInfoModel.h"
#import "ServiceNewsViewController.h"
#import "SalaryInfoViewController.h"
#import "SecondLevelViewController.h"
#import "ChangeMyPersionInfoViewController.h"
#import "ChangePasswordViewController.h"
#import "BindEmailViewController.h"
#import "FeedBackViewController.h"
#import "AboutViewController.h"
#import "JSONKit/JSONKit.h"
#import "ShowMessageNumberButton.h"
#import "NewsDetailViewController.h"
#import "MeetingDetailViewController.h"

#import "Mycrypt.h"

#define tophight 64

@interface ViewController ()<ServiceNewsViewControllerDelegate>

@end

@implementation ViewController
@synthesize btnForHeadImage;

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    arrayForMessageCount = [[NSMutableArray alloc]init];
    arrayForIcons = [[NSMutableArray alloc]init];
    btnForHeadImage.layer.masksToBounds = YES;
    btnForHeadImage.layer.cornerRadius = 20;
    
    [self createPopView];
    viewForPersonInfo.alpha = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOk) name:@"loginOk" object:nil];
    //// 推送通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushAction:) name:@"pushAction" object:nil];
    arrayForFoundtion = [[NSMutableArray alloc]init];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *username = [d objectForKey:@"username"];
    NSString *pas = [d objectForKey:@"password"];
    if((username!=nil)&&(pas!=nil)&&(![username isEqualToString:@""])&&(![pas isEqualToString:@""]))
    {
        [self loginAction];
    }else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        LoginViewController * loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (arrayForIcons.count>0) {
        [self getMessageCount];
    }
}

///推送操作
-(IBAction)pushAction:(NSNotification*)message
{
    NSDictionary * dicForPush = message.object;
    NSString *strforType = [dicForPush objectForKey:@"Type"];
    if ([strforType isEqualToString:@"NEWS"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        NewsDetailViewController * newsDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"newsDetailViewController"];
        newsDetailViewController.strForNewsId = [NSString stringWithFormat:@"%@",[dicForPush objectForKey:@"Id"]];
        [self.navigationController pushViewController:newsDetailViewController animated:YES];
    }else if ([strforType isEqualToString:@"WJ"]) {
        
    }else if ([strforType isEqualToString:@"Meeting"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MeetingDetailViewController * meetingDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingDetailViewController"];
        meetingDetailViewController.strForMeetingId = [[NSString alloc]initWithString:[dicForPush objectForKey:@"Id"]];
        [self.navigationController pushViewController:meetingDetailViewController animated:YES];
    }else if ([strforType isEqualToString:@"Payrolls"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        SalaryInfoViewController * salaryInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"salaryInfoViewController"];
        salaryInfoViewController.chooseYear = [[dicForPush objectForKey:@"Year"] intValue];
        salaryInfoViewController.choosemonth = [[dicForPush objectForKey:@"Month"]intValue];
        [self.navigationController pushViewController:salaryInfoViewController animated:YES];
    }
}

////更新项目////
-(void)getVersionInfo
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 10000;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_Edition_Check\","];
    NSString *str2 = [NSString stringWithFormat:@"\"VersionType\":\"%@\",", @"IOS"];
    NSString *str3 = [NSString stringWithFormat:@"\"VersionPackage\":\"%@\",", @"com.shanghai.subway"];
    NSString *str4 = [NSString stringWithFormat:@"\"LoginId\":\"%@\"}", [d objectForKey:@"LoginId"]];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void)isChangeVersion
{
    NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    NSString * currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    NSString * maxVersion = [dicForVersion objectForKey:@"MaxVersion"];
    NSString * minVersion = [dicForVersion objectForKey:@"MinVersionCode"];
    NSString * newVersion = [dicForVersion objectForKey:@"NewVersion"];
    NSString * versionNote = [Mycrypt decryptWithText:[dicForVersion objectForKey:@"NewVersionNote"]] ;
    
    
    if (minVersion!=nil) {
        if ([minVersion floatValue]>[currentVersion floatValue]) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"更新" message:versionNote delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertView.tag = 10001;    ///强制更新
            [alertView show];
        }else if ([newVersion floatValue]>[currentVersion floatValue])
        {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"更新" message:versionNote delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"以后更新", nil];
            alertView.tag = 10001;    ///强制更新
            [alertView show];
        }
    }
}

////


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createPopView
{
    btnforbackground = [UIButton buttonWithType:UIButtonTypeCustom];
    btnforbackground.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [btnforbackground setBackgroundColor:[UIColor clearColor]];
    btnforbackground.tag = 100;
    btnforbackground.alpha = 0.5;
    [btnforbackground addTarget:self action:@selector(removePersonInfoView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnforbackground];
    
    viewForPersonInfo = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-170, 62, 160, 250)];
    [viewForPersonInfo setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewForPersonInfo];
    
    UIImageView * imageViewbackground1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 160, 20)];
    imageViewbackground1.image = [UIImage imageNamed:@"下拉框上"];
    UIImageView * imageViewbackground2;
    UIImageView * imageViewbackground3;
    imageViewbackground2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 160, 210)];
    imageViewbackground2.image = [UIImage imageNamed:@"下拉框中"];
    imageViewbackground3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 230, 160, 20)];
    imageViewbackground3.image = [UIImage imageNamed:@"下拉框下"];
    [viewForPersonInfo addSubview:imageViewbackground1];
    [viewForPersonInfo addSubview:imageViewbackground2];
    [viewForPersonInfo addSubview:imageViewbackground3];
    
    UIImageView * imageViewForperson = [[UIImageView alloc]initWithFrame:CGRectMake(10, 18, 14, 14)];
    imageViewForperson.image = [UIImage imageNamed:@"syIcon_03"];
    [viewForPersonInfo addSubview:imageViewForperson];
    UILabel * labelForperson = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 120, 40)];
    labelForperson.text = @"个人信息";
    labelForperson.font = [UIFont systemFontOfSize:13];
    labelForperson.textColor = [UIColor blackColor];
    [viewForPersonInfo addSubview:labelForperson];
    UIButton * btnForChangePersonInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForChangePersonInfo.frame = CGRectMake(10, 5, 140, 40);
    [btnForChangePersonInfo addTarget:self action:@selector(changePersonInfo:) forControlEvents:UIControlEventTouchUpInside];
    [btnForChangePersonInfo setBackgroundColor:[UIColor clearColor]];
    [viewForPersonInfo addSubview:btnForChangePersonInfo];
    UIImageView * imageViewLine2 = [[UIImageView alloc]initWithFrame:CGRectMake(4, 45, 152, 1)];
    [imageViewLine2 setBackgroundColor:[UIColor grayColor]];
    imageViewLine2.alpha = 0.5;
    [viewForPersonInfo addSubview:imageViewLine2];
    
    UIImageView * imageViewForpersonPassword = [[UIImageView alloc]initWithFrame:CGRectMake(10, 58, 14, 14)];
    imageViewForpersonPassword.image = [UIImage imageNamed:@"syIcon_03"];
    [viewForPersonInfo addSubview:imageViewForpersonPassword];
    UILabel * labelForpersonPassword = [[UILabel alloc]initWithFrame:CGRectMake(30, 45, 120, 40)];
    labelForpersonPassword.text = @"修改密码";
    labelForpersonPassword.font = [UIFont systemFontOfSize:13];
    labelForpersonPassword.textColor = [UIColor blackColor];
    [viewForPersonInfo addSubview:labelForpersonPassword];
    UIButton * btnForChangePersonPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForChangePersonPassword.frame = CGRectMake(10, 45, 140, 40);
    [btnForChangePersonPassword addTarget:self action:@selector(changePersonPassword:) forControlEvents:UIControlEventTouchUpInside];
    [btnForChangePersonPassword setBackgroundColor:[UIColor clearColor]];
    [viewForPersonInfo addSubview:btnForChangePersonPassword];
    UIImageView * imageViewLine21 = [[UIImageView alloc]initWithFrame:CGRectMake(4, 85, 152, 1)];
    [imageViewLine21 setBackgroundColor:[UIColor grayColor]];
    imageViewLine21.alpha = 0.5;
    [viewForPersonInfo addSubview:imageViewLine21];
    
    UIImageView * imageViewForEmail = [[UIImageView alloc]initWithFrame:CGRectMake(10, 98, 14, 14)];
    imageViewForEmail.image = [UIImage imageNamed:@"syIcon_07"];
    [viewForPersonInfo addSubview:imageViewForEmail];
    UILabel * labelForEmail = [[UILabel alloc]initWithFrame:CGRectMake(30, 85, 120, 40)];
    labelForEmail.text = @"绑定邮箱";
    labelForEmail.font = [UIFont systemFontOfSize:13];
    labelForEmail.textColor = [UIColor blackColor];
    [viewForPersonInfo addSubview:labelForEmail];
    UIButton * btnForBindEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForBindEmail.frame = CGRectMake(10, 85, 140, 40);
    [btnForBindEmail addTarget:self action:@selector(changebindEmail:) forControlEvents:UIControlEventTouchUpInside];
    [btnForBindEmail setBackgroundColor:[UIColor clearColor]];
    [viewForPersonInfo addSubview:btnForBindEmail];
    UIImageView * imageViewLine3 = [[UIImageView alloc]initWithFrame:CGRectMake(4, 125, 152, 1)];
    [imageViewLine3 setBackgroundColor:[UIColor grayColor]];
    imageViewLine3.alpha = 0.5;
    [viewForPersonInfo addSubview:imageViewLine3];
    
    UIImageView * imageViewForFeelback = [[UIImageView alloc]initWithFrame:CGRectMake(10, 138, 14, 14)];
    imageViewForFeelback.image = [UIImage imageNamed:@"syIcon_10"];
    [viewForPersonInfo addSubview:imageViewForFeelback];
    UILabel * labelForFeelback = [[UILabel alloc]initWithFrame:CGRectMake(30, 125, 120, 40)];
    labelForFeelback.text = @"反馈";
    labelForFeelback.font = [UIFont systemFontOfSize:13];
    labelForFeelback.textColor = [UIColor blackColor];
    [viewForPersonInfo addSubview:labelForFeelback];
    UIButton * btnForFeelback = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForFeelback.frame = CGRectMake(10, 125, 140, 40);
    [btnForFeelback addTarget:self action:@selector(feelback:) forControlEvents:UIControlEventTouchUpInside];
    [btnForFeelback setBackgroundColor:[UIColor clearColor]];
    [viewForPersonInfo addSubview:btnForFeelback];
    UIImageView * imageViewLine4 = [[UIImageView alloc]initWithFrame:CGRectMake(4, 165, 152, 1)];
    [imageViewLine4 setBackgroundColor:[UIColor grayColor]];
    imageViewLine4.alpha = 0.5;
    [viewForPersonInfo addSubview:imageViewLine4];
    
    UIImageView * imageViewForAbout = [[UIImageView alloc]initWithFrame:CGRectMake(10, 178, 14, 14)];
    imageViewForAbout.image = [UIImage imageNamed:@"syIcon_13"];
    [viewForPersonInfo addSubview:imageViewForAbout];
    UILabel * labelForAbout = [[UILabel alloc]initWithFrame:CGRectMake(30, 165, 120, 40)];
    labelForAbout.text = @"关于";
    labelForAbout.font = [UIFont systemFontOfSize:13];
    labelForAbout.textColor = [UIColor blackColor];
    [viewForPersonInfo addSubview:labelForAbout];
    UIButton * btnForAbout = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForAbout.frame = CGRectMake(10, 165, 140, 40);
    [btnForAbout addTarget:self action:@selector(getAbout:) forControlEvents:UIControlEventTouchUpInside];
    [btnForAbout setBackgroundColor:[UIColor clearColor]];
    [viewForPersonInfo addSubview:btnForAbout];
    UIImageView * imageViewLine5 = [[UIImageView alloc]initWithFrame:CGRectMake(4, 205, 152, 1)];
    [imageViewLine5 setBackgroundColor:[UIColor grayColor]];
    imageViewLine5.alpha = 0.5;
    [viewForPersonInfo addSubview:imageViewLine5];
    
    UIImageView * imageViewForRelogin = [[UIImageView alloc]initWithFrame:CGRectMake(10, 218, 14, 14)];
    imageViewForRelogin.image = [UIImage imageNamed:@"syIcon_13"];
    [viewForPersonInfo addSubview:imageViewForRelogin];
    UILabel * labelForRelogin = [[UILabel alloc]initWithFrame:CGRectMake(30, 205, 120, 40)];
    labelForRelogin.text = @"注销";
    labelForRelogin.font = [UIFont systemFontOfSize:13];
    labelForRelogin.textColor = [UIColor blackColor];
    [viewForPersonInfo addSubview:labelForRelogin];
    UIButton * btnForRelogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForRelogin.frame = CGRectMake(10, 205, 140, 40);
    [btnForRelogin addTarget:self action:@selector(relogin:) forControlEvents:UIControlEventTouchUpInside];
    [btnForRelogin setBackgroundColor:[UIColor clearColor]];
    [viewForPersonInfo addSubview:btnForRelogin];
    
    viewForPersonInfo.alpha = 0;
    btnforbackground.alpha = 0;
    btnForHeadImage.tag = 1000;
    
}

-(IBAction)showPersonInfo:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 1000) {
        btnforbackground.alpha = 1;
        viewForPersonInfo.alpha = 1;
        btnForHeadImage.tag = 1001;
        [self.view bringSubviewToFront:btnforbackground];
        [self.view bringSubviewToFront:viewForPersonInfo];
    }else{
        viewForPersonInfo.alpha = 0;
        btnforbackground.alpha = 0;
        btnForHeadImage.tag = 1000;
    }
}

-(IBAction)removePersonInfoView:(id)sender
{
    viewForPersonInfo.alpha = 0;
    btnForHeadImage.tag =1000;
    btnforbackground.alpha = 0;
}

-(IBAction)changePersonInfo:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ChangeMyPersionInfoViewController * changeMypersionInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"changeMypersionInfoViewController"];
    [self.navigationController pushViewController:changeMypersionInfoViewController animated:YES];
}

-(IBAction)changebindEmail:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    BindEmailViewController * bindEmailViewController = [storyboard instantiateViewControllerWithIdentifier:@"BindEmailViewController"];
    [self.navigationController pushViewController:bindEmailViewController animated:YES];
}

-(IBAction)feelback:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    FeedBackViewController * feedbackViewController = [storyboard instantiateViewControllerWithIdentifier:@"feedbackViewController"];
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}

-(IBAction)getAbout:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    AboutViewController * aboutViewController = [storyboard instantiateViewControllerWithIdentifier:@"aboutViewController"];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}

-(IBAction)changePersonPassword:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ChangePasswordViewController * changePasswordViewController = [storyboard instantiateViewControllerWithIdentifier:@"changePasswordViewController"];
    [self.navigationController pushViewController:changePasswordViewController animated:YES];
}

- (void)loginAction {
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
    request.tag = 300;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"Login\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginName\":\"%@\",", [d objectForKey:@"username"]];
    NSString *str3 = [NSString stringWithFormat:@"\"ClientID\":\"%@\",", @"123456789"];
    NSString *str4 = [NSString stringWithFormat:@"\"Password\":\"%@\"}", [d objectForKey:@"password"]];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void)loginOk
{
    ////获取首页所有iconbutton//
    [self getfunction];
    [self getVersionInfo];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString * str = [d objectForKey:@"LoginImgUrl"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *imageDataForNews = [NSData dataWithContentsOfURL:[NSURL URLWithString:[d objectForKey:@"LoginImgUrl"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            btnForHeadImage.layer.masksToBounds = YES;
            btnForHeadImage.layer.cornerRadius = 10;
            [btnForHeadImage setBackgroundImage:[UIImage imageWithData:imageDataForNews] forState:UIControlStateNormal];
        });
    });
    
    labelForname.text = [d objectForKey:@"FullName"];
    labelForCompany.text = [d objectForKey:@"CompanyName"];
    labelForPost.text = [d objectForKey:@"PostName"];
    labelForSection.text = [d objectForKey:@"DepartmentName"];

}

///获取首页所有功能信息
-(void)getfunction
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, index];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 305;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"MessageTypeInfo\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\"}", [d objectForKey:@"LoginId"]];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void)addButtons
{
    for (int i=0; i<arrayForFoundtion.count; i++) {
        NSDictionary * dic;
        for (dic in arrayForIcons) {
            if ([[dic objectForKey:@"type"] isEqual:[[arrayForFoundtion objectAtIndex:i] objectForKey:@"Type"]]) {
                break;
            }
        }
        UIImage * imageForIcon = [UIImage imageWithData:[dic objectForKey:@"imagedata"]];
        NSLog(@"%f------%f", imageForIcon.size.width, imageForIcon.size.height);
        
        int x, y, interval;
        interval = ([UIScreen mainScreen].bounds.size.width-imageForIcon.size.width/2*4)/5;
        x = interval*(1+i%4) + i%4*imageForIcon.size.width/2;
        y = 35*(i/4 + 1) + tophight + imageForIcon.size.height/2*(i/4);
        
        NSLog(@"%d------%d", x, y);
        ShowMessageNumberButton * btn = [ShowMessageNumberButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, imageForIcon.size.width/2, imageForIcon.size.height/2);
        [btn setBackgroundImage:imageForIcon forState:UIControlStateNormal];
        btn.tag = [[[arrayForFoundtion objectAtIndex:i] objectForKey:@"Type"] intValue];
        [btn addTarget:self action:@selector(btnActionChoose:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn addMessageNumber];
        btn.imageViewForMessageBackground.alpha = 0;
        btn.labelForNumber.alpha = 0;
        
        UILabel * labelForBtn =[[UILabel alloc]initWithFrame:CGRectMake(x, y+imageForIcon.size.height/2+5, imageForIcon.size.width/2, 21)];
        labelForBtn.font = [UIFont systemFontOfSize:12];
        labelForBtn.textAlignment = NSTextAlignmentCenter;
        labelForBtn.tag = [[[arrayForFoundtion objectAtIndex:i] objectForKey:@"Type"] intValue]+100;
        labelForBtn.text = [[arrayForFoundtion objectAtIndex:i] objectForKey:@"TypeName"];
        labelForBtn.textColor = [UIColor blackColor];
        [self.view addSubview:labelForBtn];
    }
    
    [self getMessageCount];
}

-(void)getIcons
{
    for (int i =0; i<arrayForFoundtion.count; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int number = i;
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[arrayForFoundtion objectAtIndex:number] objectForKey:@"TypeImgUrl"]]];
            NSDictionary * dic = [[NSDictionary alloc]initWithObjectsAndKeys:imageData, @"imagedata",[[arrayForFoundtion objectAtIndex:number] objectForKey:@"Type"], @"type", nil];
            [arrayForIcons addObject:dic];
            
            if (arrayForIcons.count==arrayForFoundtion.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addButtons];
                });
            }
        });
    }
}


///首页图标显示未读消息数量接口
-(void)getMessageCount
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSMutableArray * arrForTypeModel = [[NSMutableArray alloc]init];
    for (int i =0; i<arrayForFoundtion.count; i++) {
        NSDictionary * dic = [[NSDictionary alloc]initWithObjectsAndKeys:[[arrayForFoundtion objectAtIndex:i] objectForKey:@"Type"],@"Type", [[arrayForFoundtion objectAtIndex:i] objectForKey:@"DepartmentId"], @"DepartmentId", nil];
        [arrForTypeModel addObject:dic];
    }
    
    NSData * data = [arrForTypeModel JSONData];
    NSString *json =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, index];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 310;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"MessageCount_All\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"IndexTypeModel\":%@}",json];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void)showNewsNumber
{
    
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        NSDictionary *dic = [arrayForMessageCount objectAtIndex:i];
        if([[dic objectForKey:@"Count"] intValue]==0)
            continue;
        
        for (ShowMessageNumberButton * btn in self.view.subviews) {
            if (btn.tag == [[dic objectForKey:@"Type"] intValue]) {
                btn.imageViewForMessageBackground.alpha = 1;
                btn.labelForNumber.alpha = 1;
                btn.labelForNumber.text = [dic objectForKey:@"Count"];
                break;
            }
        }
    }
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSendDeviceToken" object:nil];
            NSDictionary * dicForUserInfo = [result objectForKey:@"Message"];
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
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
            [MBProgressHUD hideHUDForView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginOk" object:nil];
        }
        else {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            LoginViewController * loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
            [self.navigationController pushViewController:loginViewController animated:YES];
        }
        
    }
    if (_request.tag == 305) {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [arrayForFoundtion addObjectsFromArray:[result objectForKey:@"Message"]];
            [self getIcons];
        }
        else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
    if (_request.tag == 310) {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [arrayForMessageCount removeAllObjects];
            [arrayForMessageCount addObjectsFromArray:[result objectForKey:@"Message"]];
            [self showNewsNumber];
        }else{
            
        }
    }
    
    if (_request.tag == 10000) {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            dicForVersion = [[NSDictionary alloc]initWithDictionary:[result objectForKey:@"Message"]];
            [self isChangeVersion];
        }
        else if ([[result objectForKey:@"State"] isEqualToString:@"Error"]) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:[result objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"网络请求失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 200){
        if (buttonIndex == 0) {
            for (UIButton * btn in self.view.subviews) {
                if (btn.tag<=15 && btn.tag>=1) {
                    [btn removeFromSuperview];
                }
            }
            for (UILabel * lab in self.view.subviews) {
                if (lab.tag<=115 && lab.tag>=101) {
                    [lab removeFromSuperview];
                }
            }
            [arrayForFoundtion removeAllObjects];
            [arrayForIcons removeAllObjects];
            [self removePersonInfoView:nil];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            LoginViewController * loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
            [self.navigationController pushViewController:loginViewController animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldLogOutDeviceToken" object:nil];
        }
    }
    if (alertView.tag == 10001) {
        if (buttonIndex == 0) {
            NSString * appFileUrl = [dicForVersion objectForKey:@"NewAPPFileUrl"];
            NSURL *url  = [NSURL URLWithString:appFileUrl];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
}

- (IBAction)relogin:(id)sender {
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"确定注销？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alertView.tag = 200;
    [alertView show];
}

//////根据tag 选择进行操作
-(IBAction)btnActionChoose:(id)sender
{
    ShowMessageNumberButton * btn = (ShowMessageNumberButton *)sender;
    switch (btn.tag) {
        case 1:
            [self actionForDang:sender];
            break;
        case 2:
            [self actionForJian:sender];
            break;
        case 3:
            [self actionForGong:sender];
            break;
        case 4:
            [self actionForTuan:sender];
            break;
        case 5:
            [self actionForZong:sender];
            break;
        case 6:
            [self actionForZhu:sender];
            break;
        case 7:
            [self actionForSalary:sender];
            break;
        case 8:
            [self actionForKe:sender];
            break;
        case 9:
            [self actionForCheng:sender];
            break;
        case 10:
            [self actionForZhi:sender];
            break;
        case 11:
            [self actionForShe:sender];
            break;
        case 12:
            [self actionFor2:sender];
            break;
        case 13:
            [self actionFor11:sender];
            break;
        case 14:
            [self actionFor13:sender];
            break;
        case 15:
            [self actionFor17:sender];
            break;
        default:
            break;
    }
}


- (IBAction)actionForDang:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"1"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"1"]) {
            break;
        }
    }
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
//    secondLevelViewController.typeNumber = 1;
//    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
//    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
//    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
//    [secondLevelViewController getIcons];
//    [self.navigationController pushViewController:secondLevelViewController animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ServiceNewsViewController * serviceNewsViewController = [storyboard instantiateViewControllerWithIdentifier:@"serviceNewsViewController"];
    serviceNewsViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    serviceNewsViewController.strFortitle = @"公司新闻";
    //    serviceNewsViewController.delegate = self;
    serviceNewsViewController.tagNumber = -1;
    [self.navigationController pushViewController:serviceNewsViewController animated:YES];
}

- (IBAction)actionForJian:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"2"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"2"]) {
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 2;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForGong:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"3"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"3"]) {
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 3;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForTuan:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"4"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"4"]) {
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 4;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForZong:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"5"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"5"]) {
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 5;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForZhu:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"6"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"6"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 6;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForSalary:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"7"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"7"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 7;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForKe:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"8"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"8"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 8;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForCheng:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"9"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"9"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 9;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForZhi:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"10"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"10"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 10;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionForShe:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"11"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"11"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 11;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionFor2:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"12"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"12"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 12;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionFor11:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"13"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"13"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 13;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionFor13:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"14"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"14"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 14;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}

- (IBAction)actionFor17:(id)sender {
    NSDictionary *dic;
    for (dic in arrayForFoundtion) {
        if ([[dic objectForKey:@"Type"] isEqual:@"15"]) {
            break;
        }
    }
    NSDictionary *dicmessage;
    for (int i = 0; i<arrayForMessageCount.count; i++) {
        dicmessage = [arrayForMessageCount objectAtIndex:i];
        if ([[dicmessage objectForKey:@"Type"] isEqual:@"15"]) {
            break;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondLevelViewController * secondLevelViewController = [storyboard instantiateViewControllerWithIdentifier:@"secondLevelViewController"];
    secondLevelViewController.typeNumber = 15;
    secondLevelViewController.FirstdepartmentId = [dic objectForKey:@"DepartmentId"];
    secondLevelViewController.DicForFoundtion = [[NSDictionary alloc]initWithDictionary:dic];
    secondLevelViewController.arrayForChildrenMessageCount = [[NSMutableArray alloc]initWithArray:[dicmessage objectForKey:@"Children"]];
    [secondLevelViewController getIcons];
    [self.navigationController pushViewController:secondLevelViewController animated:YES];
}


///////coredata 数据存储////////
-(void)insertCoreData:(NSDictionary *)dataDic
{
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    UserInfoModel *userInfoModel = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfoModel" inManagedObjectContext:context];
    userInfoModel.loginimgurl = [dataDic objectForKey:@"LoginImgUrl"];
    userInfoModel.companyname = [dataDic objectForKey:@"CompanyName"];
    if ([dataDic objectForKey:@"Signature"]) {
        userInfoModel.signature = [dataDic objectForKey:@"Signature"];
    }else{
        userInfoModel.signature = @"";
    }
    userInfoModel.fullname =[dataDic objectForKey:@"FullName"];
    userInfoModel.loginid = [dataDic objectForKey:@"LoginId"];
    userInfoModel.companyid =[dataDic objectForKey:@"CompanyId"];
    userInfoModel.departmentname = [dataDic objectForKey:@"DepartmentName"];
    userInfoModel.postname = [dataDic objectForKey:@"PostName"];
    userInfoModel.departmentid = [dataDic objectForKey:@"DepartmentId"];
    
    NSError *error;
    if(![context save:&error])
    {
        NSLog(@"不能保存：%@",[error localizedDescription]);
    }
}

//更新
- (void)updateData:(NSDictionary *)dataDic
{
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfoModel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count>0) {
        UserInfoModel *userInfoModel = [fetchedObjects objectAtIndex:0];
        userInfoModel.loginimgurl = [dataDic objectForKey:@"LoginImgUrl"];
        userInfoModel.companyname = [dataDic objectForKey:@"CompanyName"];
        if ([dataDic objectForKey:@"Signature"]) {
            userInfoModel.signature = [dataDic objectForKey:@"Signature"];
        }else{
            userInfoModel.signature = @"";
        }
        userInfoModel.fullname =[dataDic objectForKey:@"FullName"];
        userInfoModel.loginid = [dataDic objectForKey:@"LoginId"];
        userInfoModel.companyid =[dataDic objectForKey:@"CompanyId"];
        userInfoModel.departmentname = [dataDic objectForKey:@"DepartmentName"];
        if ([dataDic objectForKey:@"PostName"]) {
            userInfoModel.postname = [dataDic objectForKey:@"PostName"];
        }else{
            userInfoModel.postname = @"";
        }
        userInfoModel.departmentid = [dataDic objectForKey:@"DepartmentId"];
    }else{
        UserInfoModel *userInfoModel = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfoModel" inManagedObjectContext:context];
        userInfoModel.loginimgurl = [dataDic objectForKey:@"LoginImgUrl"];
        userInfoModel.companyname = [dataDic objectForKey:@"CompanyName"];
        if ([dataDic objectForKey:@"Signature"]) {
            userInfoModel.signature = [dataDic objectForKey:@"Signature"];
        }else{
            userInfoModel.signature = @"";
        }
        userInfoModel.fullname =[dataDic objectForKey:@"FullName"];
        userInfoModel.loginid = [dataDic objectForKey:@"LoginId"];
        userInfoModel.companyid =[dataDic objectForKey:@"CompanyId"];
        userInfoModel.departmentname = [dataDic objectForKey:@"DepartmentName"];
        if ([dataDic objectForKey:@"PostName"]) {
            userInfoModel.postname = [dataDic objectForKey:@"PostName"];
        }else{
            userInfoModel.postname = @"";
        }
        userInfoModel.departmentid = [dataDic objectForKey:@"DepartmentId"];
    }
    
    //保存
    if ([context save:&error]) {
        //更新成功
        NSLog(@"更新成功");
    }
}

@end
