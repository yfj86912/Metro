//
//  MeetingDetailViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/4.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MeetingDetailViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface MeetingDetailViewController ()
{
    NSMutableDictionary *dicForMeetingDetail;
    UIScrollView * scrollview;
}
@end

@implementation MeetingDetailViewController
@synthesize labelForAddress, labelForEndTime, labelForMeetingCompere, labelForMeetingName, labelForStartTime, viewForbackground;
@synthesize strForMeetingId;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 180, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-300)];
    [viewForbackground addSubview:scrollview];
    [self getMeetingDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showDetail
{
    labelForMeetingName.text = [dicForMeetingDetail objectForKey:@"MeetingName"];
    labelForAddress.text = [dicForMeetingDetail objectForKey:@"MeetingPlace"];
    labelForStartTime.text =[dicForMeetingDetail objectForKey:@"MeetingBeginDate"];
    labelForEndTime.text = [dicForMeetingDetail objectForKey:@"MeetingEndDate"];
    labelForMeetingCompere.text = [dicForMeetingDetail objectForKey:@"MeetingHost"];
    
    NSString *str = [dicForMeetingDetail objectForKey:@"MeetingUser"];
    NSArray * arr = [str componentsSeparatedByString:@","];
    for (int i =0 ; i<arr.count; i++) {
        NSString * strForname = [arr objectAtIndex:i];
        UILabel *labelForUser = [[UILabel alloc]initWithFrame:CGRectMake(((viewForbackground.frame.size.width-240)/5)*(i%4+1)+(i%4)*60, 10+(i/4)*44, 60, 44)];
        labelForUser.font = [UIFont systemFontOfSize:12];
        labelForUser.text = strForname;
        labelForUser.textAlignment = NSTextAlignmentCenter;
        labelForUser.textColor = [UIColor blackColor];
        [scrollview addSubview:labelForUser];
    }
    if (arr.count%4==0) {
        scrollview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 20+(arr.count/4)*44);
    }else{
        scrollview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 20+(arr.count/4 + 1)*44);
    }
}

////获取我的会议详情
- (void)getMeetingDetail
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, bgs];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1001;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_HY_MeetingInfo_ById\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"MeetingId\":\"%@\"}",strForMeetingId];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
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
    if(_request.tag == 1001)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            dicForMeetingDetail = [[NSMutableDictionary alloc]initWithDictionary:[result objectForKey:@"Message"]];
            [self showDetail];
            [MBProgressHUD hideHUDForView:self.view];
        }else {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
        
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"获取会议详情失败，请检查网络！"];
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
@end
