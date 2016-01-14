//
//  MeetingReserveStepThridViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/10.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MeetingReserveStepThridViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "JSONKit/JSONKit.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"
#import "TwoGradeButton.h"

@interface MeetingReserveStepThridViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView * tableViewForpersons;
    NSMutableArray * arrayForUserList;
    NSMutableArray * arrayForChooseList;
    
    UIView *viewForpersons;
    
    UIButton * btnForBefor;
    UIButton * btnForUpLoad;
    
    int chooseCellNumber;
    int heightTwo; ///二级菜单高度
}

@end

@implementation MeetingReserveStepThridViewController
@synthesize dicForMeetingPlace, strForBeginDate, strForEndDate, strForMeetingHost, strForMeetingName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tableViewForpersons = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 210)];
    tableViewForpersons.delegate = self;
    tableViewForpersons.dataSource = self;
    tableViewForpersons.bounces = NO;
    tableViewForpersons.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableViewForpersons];
    
    arrayForUserList = [[NSMutableArray alloc]init];
    arrayForChooseList = [[NSMutableArray alloc]init];
    
    btnForBefor = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForBefor.frame = CGRectMake(30, CGRectGetMaxY(tableViewForpersons.frame)+30, 100, 40);
    [btnForBefor setTitle:@"上一步" forState:UIControlStateNormal];
    [btnForBefor setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForBefor setBackgroundColor:[UIColor grayColor]];
    [btnForBefor addTarget:self action:@selector(goBefor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnForBefor];
    
    btnForUpLoad = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForUpLoad.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-130, CGRectGetMaxY(tableViewForpersons.frame)+30, 100, 40);
    [btnForUpLoad setTitle:@"提交" forState:UIControlStateNormal];
    [btnForUpLoad setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForUpLoad setBackgroundColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1]];
    [btnForUpLoad addTarget:self action:@selector(upLoadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnForUpLoad];
    
    [self chooseMeetingPeople];
    chooseCellNumber =0 ;
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

////获取公司人员信息
- (void)chooseMeetingPeople
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, pub];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1601;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"GG_UserList_Tree\","];
    NSString *str2 = [NSString stringWithFormat:@"\"CompanyId\":\"%@\",", [d objectForKey:@"CompanyId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"LoginId\":\"%@\"}", [d objectForKey:@"LoginId"]];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}


///提交会议预定
-(void)upLoadMeetingInfo
{
    if (arrayForChooseList.count==0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请选择参会人员" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *strForUsers = [[NSMutableString alloc]initWithString:@","];
    for (int i =0 ; i<arrayForChooseList.count; i++) {
        strForUsers = [strForUsers stringByAppendingFormat:@"%@,",[[arrayForChooseList objectAtIndex:i] objectForKey:@"id"]];
    }
    [MBProgressHUD showMessage:@"提交会议预定..." toView:self.view];
    NSArray *arrForBegin = [strForBeginDate componentsSeparatedByString:@" "];
    NSArray *arrForEnd = [strForBeginDate componentsSeparatedByString:@" "];
    NSMutableDictionary * dicForScheduleModel = [[NSMutableDictionary alloc]init];
    [dicForScheduleModel setValue:strForMeetingName forKey:@"MeetingName"];
    [dicForScheduleModel setValue:strForMeetingHost forKey:@"MeetingHost"];
    [dicForScheduleModel setValue:[arrForBegin objectAtIndex:0] forKey:@"MeetingBeginDate"];
    [dicForScheduleModel setValue:[arrForEnd objectAtIndex:0] forKey:@"MeetingEndDate"];
    [dicForScheduleModel setValue:[arrForBegin objectAtIndex:1] forKey:@"StartType"];
    [dicForScheduleModel setValue:[arrForEnd objectAtIndex:1] forKey:@"EndType"];
    [dicForScheduleModel setValue:[dicForMeetingPlace objectForKey:@"SiteName"] forKey:@"MeetingPlace"];
    [dicForScheduleModel setValue:[dicForMeetingPlace objectForKey:@"Id"] forKey:@"SiteId"];
    [dicForScheduleModel setValue:strForUsers forKey:@"MeetingUser"];
    
    NSData * data = [dicForScheduleModel JSONData];
    NSString *json =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, bgs];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1602;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_HY_Scheduled\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"ScheduledModel\":%@}",json];
    
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
    if(_request.tag == 1601)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [arrayForUserList addObjectsFromArray:[result objectForKey:@"Message"]];
            [tableViewForpersons reloadData];
            [MBProgressHUD hideHUDForView:self.view];
        }else {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
    else if (_request.tag == 1602)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showSuccess:[result objectForKey:@"Message"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoHere" object:nil];
        }else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"请求失败，请检查网络！"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == chooseCellNumber) {
        NSDictionary * dic = [arrayForUserList objectAtIndex:indexPath.row];
        heightTwo=0;
        NSMutableArray * arr = [[NSMutableArray alloc]initWithArray:[dic objectForKey:@"children"]];
        for (int i=0; i<arr.count; i++) {
            NSDictionary * dicTwo = [arr objectAtIndex:0];
            if ([dicTwo objectForKey:@"children"]) {
                NSArray * arrTwo = [dicTwo objectForKey:@"children"];
                if (arrTwo.count%4==0) {
                    heightTwo = heightTwo +1+(arrTwo.count/4);
                }else{
                    heightTwo = heightTwo +1+(arrTwo.count/4+1);
                }
                [arr removeObject:dicTwo];
                i--;
            }
            
        }
        
        if (arr.count%5==0) {
            heightTwo =  arr.count/5+1 + heightTwo;
            return heightTwo*44;
        }else{
            heightTwo =  arr.count/5+2 + heightTwo;
            return heightTwo*44;
        }
        
    }
    return 44;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrayForUserList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * dic = [arrayForUserList objectAtIndex:indexPath.row];
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"personTableViewCell%d", indexPath.row];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (chooseCellNumber == indexPath.row) {
        [viewForpersons removeFromSuperview];
    }
    for (UIView * view in cell.subviews) {
        [view removeFromSuperview];
    }
    
    UIImageView * imageViewForchoose = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon1"]];
    imageViewForchoose.frame = CGRectMake(30, 18, 6, 8);
    [cell addSubview: imageViewForchoose];
    
    UILabel * labelForMeetingAddress = [[UILabel alloc]initWithFrame:CGRectMake(50, 7, 200, 30)];
    labelForMeetingAddress.text = [dic objectForKey:@"name"];
    [cell addSubview:labelForMeetingAddress];
    
    if (chooseCellNumber == indexPath.row) {
        
        imageViewForchoose.image = [UIImage imageWithCGImage:imageViewForchoose.image.CGImage scale:1 orientation:UIImageOrientationRight];
        
        viewForpersons = [[UIView alloc]initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, (heightTwo-1)*44)];
        [cell addSubview: viewForpersons];
        
        NSMutableArray * arr = [[NSMutableArray alloc]initWithArray:[dic objectForKey:@"children"]];
        int heightForever=0;
        for (int i=0 ,m=0; i<arr.count; i++, m++) {
            NSDictionary * dicTwo = [arr objectAtIndex:0];
            if ([dicTwo objectForKey:@"children"]) {
                UIImageView * imageViewForchooseTwo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon1"]];
                imageViewForchooseTwo.frame = CGRectMake(50, 18+heightForever*44, 6, 8);
                [viewForpersons addSubview: imageViewForchooseTwo];
                imageViewForchooseTwo.image = [UIImage imageWithCGImage:imageViewForchooseTwo.image.CGImage scale:1 orientation:UIImageOrientationRight];
                
                UILabel * labelForMeetingAddressTwo = [[UILabel alloc]initWithFrame:CGRectMake(70, 7+heightForever*44, 200, 30)];
                labelForMeetingAddressTwo.text = [dicTwo objectForKey:@"name"];
                [viewForpersons addSubview:labelForMeetingAddressTwo];
                
                NSArray * arrTwo = [dicTwo objectForKey:@"children"];
                
                for (int n =0 ; n<arrTwo.count; n++) {
                    NSDictionary * dicForchild = [arrTwo objectAtIndex:n];
                    TwoGradeButton *btnForname = [[TwoGradeButton alloc]initWithFrame:CGRectMake((([UIScreen mainScreen].bounds.size.width-240)/5)*(n%4+1)+(n%4)*50, (heightForever + 1 + n/4)*44, 60, 44)];
                    btnForname.titleLabel.font = [UIFont systemFontOfSize:12];
                    [btnForname setTitle:[dicForchild objectForKey:@"name"] forState:UIControlStateNormal];
                    [btnForname setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btnForname.secondGradeNumber = n;
                    btnForname.tag = m;
                    btnForname.selected = NO;
                    [btnForname addTarget:self action:@selector(choosePerson:) forControlEvents:UIControlEventTouchUpInside];
                    for (int j =0 ; j<arrayForChooseList.count; j++) {
                        NSDictionary * dicForchoosechild = [arrayForChooseList objectAtIndex:j];
                        if ([[dicForchild objectForKey:@"id"] isEqual:[dicForchoosechild objectForKey:@"id"]]) {
                            [btnForname setTitleColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1] forState:UIControlStateNormal];
                            btnForname.selected = YES;
                        }
                    }
                    [viewForpersons addSubview:btnForname];
                }
                if (arrTwo.count%4==0) {
                    heightForever = heightForever +1+(arrTwo.count/4);
                }else{
                    heightForever = heightForever +1+(arrTwo.count/4+1);
                }
                
                [arr removeObject:dicTwo];
                i--;
            }
            
        }
        
        
        for (int i =0 ; i<arr.count; i++) {
            NSDictionary * dicForchild = [arr objectAtIndex:i];
            TwoGradeButton *btnForname = [[TwoGradeButton alloc]initWithFrame:CGRectMake((([UIScreen mainScreen].bounds.size.width-250)/6)*(i%5+1)+(i%5)*50, (heightForever + i/5)*44, 50, 44)];
            btnForname.titleLabel.font = [UIFont systemFontOfSize:12];
            [btnForname setTitle:[dicForchild objectForKey:@"name"] forState:UIControlStateNormal];
            [btnForname setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnForname.tag = i;
            btnForname.secondGradeNumber = -1;
            btnForname.selected = NO;
            [btnForname addTarget:self action:@selector(choosePerson:) forControlEvents:UIControlEventTouchUpInside];
            for (int j =0 ; j<arrayForChooseList.count; j++) {
                NSDictionary * dicForchoosechild = [arrayForChooseList objectAtIndex:j];
                if ([[dicForchild objectForKey:@"id"] isEqual:[dicForchoosechild objectForKey:@"id"]]) {
                    [btnForname setTitleColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1] forState:UIControlStateNormal];
                    btnForname.selected = YES;
                }
            }
            [viewForpersons addSubview:btnForname];
        }
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (chooseCellNumber == indexPath.row) {
        return;
    }else{
        chooseCellNumber = indexPath.row;
        [tableView reloadData];
    }
}

-(IBAction)choosePerson:(id)sender
{
    TwoGradeButton * btn = (TwoGradeButton *)sender;
    NSDictionary * dic = [arrayForUserList objectAtIndex:chooseCellNumber];
    NSDictionary * dicForchoosePerson = [[dic objectForKey:@"children"] objectAtIndex:btn.tag];
    if (btn.secondGradeNumber == -1) {
        if (btn.selected) {
            [arrayForChooseList removeObject:dicForchoosePerson];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            [arrayForChooseList addObject:dicForchoosePerson];
            [btn setTitleColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1] forState:UIControlStateNormal];
        }
        btn.selected = !btn.selected;
    }else{
        NSArray * arrTwoGrade = [dicForchoosePerson objectForKey:@"children"];
        NSDictionary * dicForChooseSecondGradePerson = [arrTwoGrade objectAtIndex:btn.secondGradeNumber];
        if (btn.selected) {
            [arrayForChooseList removeObject:dicForChooseSecondGradePerson];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            [arrayForChooseList addObject:dicForChooseSecondGradePerson];
            [btn setTitleColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1] forState:UIControlStateNormal];
        }
        btn.selected = !btn.selected;
    }
    
    
}

-(IBAction)upLoadAction:(id)sender
{
    [self upLoadMeetingInfo];
}

-(IBAction)goBefor:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
