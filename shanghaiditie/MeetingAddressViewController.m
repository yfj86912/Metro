//
//  MeetingAddressViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/4.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MeetingAddressViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "MeetingAddressTableViewCell.h"
#import "MeetingAddDetailViewController.h"

@interface MeetingAddressViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * arrayForMeetingAddressInfo;
    NSMutableArray * arrayForImages;
}

@end

@implementation MeetingAddressViewController
@synthesize tableViewForAddress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableViewForAddress.delegate = self;
    tableViewForAddress.dataSource = self;
    arrayForMeetingAddressInfo = [[NSMutableArray alloc]init];
    arrayForImages = [[NSMutableArray alloc]init];

    [self getMeetingAddress];
    
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

////获取我的会议场地列表
- (void)getMeetingAddress
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
    request.tag = 601;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_HY_MeetingSite\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\"}", [d objectForKey:@"LoginId"]];
    
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
    if(_request.tag == 601)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [arrayForMeetingAddressInfo addObjectsFromArray:[result objectForKey:@"Message"]];
            [tableViewForAddress reloadData];
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
    [MBProgressHUD showError:@"获取会议场地失败，请检查网络！"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrayForMeetingAddressInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForMeetingAddressInfo objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"meetingAddressTableViewCell";
    MeetingAddressTableViewCell *cell = (MeetingAddressTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[MeetingAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ///cell恢复成最初状态
    cell.labelForTitle.text = @"";
    
    cell.labelForTitle.text = [dic objectForKey:@"SiteName"];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForMeetingAddressInfo objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MeetingAddDetailViewController * meetingAddDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingAddDetailViewController"];
    meetingAddDetailViewController.dicForAddressInfo = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [self.navigationController pushViewController:meetingAddDetailViewController animated:YES];
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
