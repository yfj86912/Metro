//
//  MeetingReserveStepTwoViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MeetingReserveStepTwoViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "MeetingReserveStepThridViewController.h"

@interface MeetingReserveStepTwoViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView * tableViewForMeetingAddress;
    NSMutableArray * arrayForMeetingAddressInfo;
    
    int chooseAddress;
    NSDictionary * dicForChooseAddress;
    
    UIButton * btnForBefor;
    UIButton * btnForNext;
}

@end

@implementation MeetingReserveStepTwoViewController
@synthesize strForBeginDate, strForEndDate;
@synthesize strForMeetingName, strForMeetingHost;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableViewForMeetingAddress = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 210)];
    tableViewForMeetingAddress.delegate = self;
    tableViewForMeetingAddress.dataSource = self;
    tableViewForMeetingAddress.bounces = NO;
    tableViewForMeetingAddress.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableViewForMeetingAddress];
    arrayForMeetingAddressInfo = [[NSMutableArray alloc]init];
    
    btnForBefor = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForBefor.frame = CGRectMake(30, CGRectGetMaxY(tableViewForMeetingAddress.frame)+30, 100, 40);
    [btnForBefor setTitle:@"上一步" forState:UIControlStateNormal];
    [btnForBefor setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForBefor setBackgroundColor:[UIColor grayColor]];
    [btnForBefor addTarget:self action:@selector(goBefor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnForBefor];
    
    btnForNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForNext.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-130, CGRectGetMaxY(tableViewForMeetingAddress.frame)+30, 100, 40);
    [btnForNext setTitle:@"下一步" forState:UIControlStateNormal];
    [btnForNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForNext setBackgroundColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1]];
    [btnForNext addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnForNext];
    chooseAddress = 0;
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
    NSArray *arrForBegin = [strForBeginDate componentsSeparatedByString:@" "];
    NSArray *arrForEnd = [strForBeginDate componentsSeparatedByString:@" "];
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_HY_SiteSelection\","];
    NSString *str2 = [NSString stringWithFormat:@"\"MeetingBeginDate\":\"%@\",", [arrForBegin objectAtIndex:0]];
    NSString *str3 = [NSString stringWithFormat:@"\"MeetingEndDate\":\"%@\",", [arrForEnd objectAtIndex:0]];
    NSString *str4 = [NSString stringWithFormat:@"\"StartType\":\"%@\",", [arrForBegin objectAtIndex:1]];
    NSString *str5 = [NSString stringWithFormat:@"\"EndType\":\"%@\",", [arrForEnd objectAtIndex:1]];
    NSString *str6 = [NSString stringWithFormat:@"\"LoginId\":\"%@\"}", [d objectForKey:@"LoginId"]];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str6 dataUsingEncoding:NSUTF8StringEncoding]];
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
            dicForChooseAddress = [[NSDictionary alloc]initWithDictionary:[arrayForMeetingAddressInfo objectAtIndex:0]];
            [tableViewForMeetingAddress reloadData];
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return  arrayForMeetingAddressInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForMeetingAddressInfo objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"AddressTableViewCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (UIView * view in cell.subviews) {
        [view removeFromSuperview];
    }
    
    UIImageView * imageViewForchoose = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    imageViewForchoose.layer.masksToBounds = YES;
    imageViewForchoose.layer.cornerRadius = 10;
    imageViewForchoose.frame = CGRectMake(50, 12, 20, 20);
    if(indexPath.row == chooseAddress)
    {
        [imageViewForchoose setBackgroundColor:[UIColor redColor]];
    }
    else{
        [imageViewForchoose setBackgroundColor:[UIColor grayColor]];
    }
    [cell addSubview: imageViewForchoose];
    
    UILabel * labelForMeetingAddress = [[UILabel alloc]initWithFrame:CGRectMake(90, 7, 200, 30)];
    labelForMeetingAddress.text = [dic objectForKey:@"SiteName"];
    [cell addSubview:labelForMeetingAddress];
    
    UIImageView * imageViewForLine = [[UIImageView alloc]initWithFrame:CGRectMake(10, 44, cell.frame.size.width-10, 0.5)];
    [imageViewForLine setBackgroundColor:[UIColor grayColor]];
    [cell addSubview:imageViewForLine];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForMeetingAddressInfo objectAtIndex:indexPath.row];
    chooseAddress = indexPath.row;
    [tableView reloadData];
    dicForChooseAddress = dic;
}


-(IBAction)goBefor:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)goNext:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MeetingReserveStepThridViewController * meetingReserveStepThridViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingReserveStepThridViewController"];
    meetingReserveStepThridViewController.dicForMeetingPlace = [[NSDictionary alloc]initWithDictionary:dicForChooseAddress];
    meetingReserveStepThridViewController.strForMeetingName = [[NSString alloc]initWithString:strForMeetingName];
    meetingReserveStepThridViewController.strForMeetingHost = [[NSString alloc]initWithString:strForMeetingHost];
    meetingReserveStepThridViewController.strForBeginDate = [[NSString alloc]initWithString:strForBeginDate];
    meetingReserveStepThridViewController.strForEndDate = [[NSString alloc]initWithString:strForEndDate];
    [self.navigationController pushViewController:meetingReserveStepThridViewController animated:YES];
}

- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refreshAction:(id)sender {
}

@end
