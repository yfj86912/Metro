//
//  MyYudingMeetingDetailViewController.m
//  shanghaiditie
//
//  Created by yfj on 15/6/8.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MyYudingMeetingDetailViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface MyYudingMeetingDetailViewController ()
{
    NSMutableDictionary *dicForMeetingDetail;
    UIScrollView * scrollview;
}

@end

@implementation MyYudingMeetingDetailViewController
@synthesize labelForAddress, labelForAudit, labelForEndTime, labelForholdName, labelForMeetingName, labelForStartTime, viewForDetail;
@synthesize strForMeetingId;
@synthesize dicForMeetingInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 180, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-300)];
    [viewForDetail addSubview:scrollview];
    [self getMeetingDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showDetail
{
    labelForMeetingName.text = [dicForMeetingInfo objectForKey:@"MeetingName"];
    switch ([[dicForMeetingInfo objectForKey:@"ExamineState"] intValue]) {
        case 1:
            labelForAudit.text = @"未审核";
            break;
        case 2:
            labelForAudit.text = @"审核通过";
            break;
        case 3:
            labelForAudit.text = @"审核不通过";
            break;
        default:
            break;
    }
    labelForholdName.text = [dicForMeetingInfo objectForKey:@"MeetingHost"];
    labelForStartTime.text =[dicForMeetingInfo objectForKey:@"MeetingBeginDate"];
    labelForAddress.text = [dicForMeetingInfo objectForKey:@"MeetingPlace"];
    labelForEndTime.text = [dicForMeetingInfo objectForKey:@"MeetingEndDate"];
    
    NSString *str = [dicForMeetingDetail objectForKey:@"MeetingUser"];
    NSArray * arr = [str componentsSeparatedByString:@","];
    
    for (int i =0 ; i<arr.count; i++) {
        NSString * strForname = [arr objectAtIndex:i];
        UILabel *labelForUser = [[UILabel alloc]initWithFrame:CGRectMake(((viewForDetail.frame.size.width-240)/5)*(i%4+1)+(i%4)*60, 10+(i/4)*44, 60, 44)];
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
    request.tag = 2001;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_HY_MeetingInfo_ById_My\","];
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
    if(_request.tag == 2001)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            dicForMeetingDetail = [[NSMutableDictionary alloc]initWithDictionary:[result objectForKey:@"Message"]];
            [self showDetail];
            [MBProgressHUD hideHUDForView:self.view];
        }else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"获取我预定会议详情失败，请检查网络！"];
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
