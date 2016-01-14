//
//  AboutViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/5/29.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "AboutViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "AboutTableViewCell1.h"
#import "AboutTableViewCell2.h"
#import "Mycrypt.h"
#import "MyDesCrypt.h"

@interface AboutViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AboutViewController
@synthesize tableViewForversion;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableViewForversion.delegate = self;
    tableViewForversion.dataSource = self;
    versionInforArr = [[NSMutableArray alloc]init];
    versionNoteArr = [[NSMutableArray alloc]init];
    isSelected = -1;
    [self getAboutInfo];
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

////获取 关于 信息
- (void)getAboutInfo
{
    [MBProgressHUD showMessage:@"正在获取数据..." toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1001;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_About_List\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"VersionType\":\"IOS\"}"];
    
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
            [versionInforArr addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            [tableViewForversion reloadData];
            [MBProgressHUD hideHUDForView:self.view];
        }else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:@"网络问题 获取失败！"];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"网络问题 获取失败！"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSelected<0) {
        return 56;
    }
    else{
        if (indexPath.row == isSelected+1) {
            return 38;
        }else{
            return 56;
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSelected<0) {
        return  versionInforArr.count;
    }else{
        return versionInforArr.count+versionNoteArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSelected<0) {
        NSDictionary * dic = [versionInforArr objectAtIndex:indexPath.row];
        
        static NSString *CellIdentifier = @"aboutTableViewCell1";
        AboutTableViewCell1 *cell = (AboutTableViewCell1*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell=[[AboutTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        ///cell恢复成最初状态
        cell.imageViewForRow.image = [UIImage imageNamed:@"icon1"];
        cell.labelForTitle.text = [NSString stringWithFormat:@"版本V%@", [dic objectForKey:@"Version"]];
        cell.labelForTime.text = [dic objectForKey:@"AddTime"];
        return cell;
    }else{
        if (indexPath.row == isSelected+1) {
            NSString * strdic = [versionNoteArr objectAtIndex:0];
            
            static NSString *CellIdentifier = @"aboutTableViewCell2";
            AboutTableViewCell2 *cell = (AboutTableViewCell2*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell=[[AboutTableViewCell2 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            ///cell恢复成最初状态
            cell.labelForContent.text = strdic;
            return cell;
        }else{
            NSDictionary * dic;
            if (indexPath.row>isSelected+1) {
                dic = [versionInforArr objectAtIndex:indexPath.row-1];
            }else{
                dic = [versionInforArr objectAtIndex:indexPath.row];
            }
            
            static NSString *CellIdentifier = @"aboutTableViewCell1";
            AboutTableViewCell1 *cell = (AboutTableViewCell1*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell=[[AboutTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            ///cell恢复成最初状态
            cell.imageViewForRow.image = [UIImage imageNamed:@"icon1"];
            cell.labelForTitle.text = [NSString stringWithFormat:@"版本V%@", [dic objectForKey:@"Version"]];
            cell.labelForTime.text = [dic objectForKey:@"AddTime"];
            return cell;
        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSelected<0 || (isSelected != indexPath.row && isSelected+1 != indexPath.row)) {
        
        [versionNoteArr removeAllObjects];
        NSString *strDec;
        if (isSelected<0 || isSelected >=indexPath.row) {
            strDec = [[versionInforArr objectAtIndex:indexPath.row] objectForKey:@"VersionNote"];
            NSString *str = [Mycrypt decryptWithText:strDec];
            //        NSString *str = [MyDesCrypt decryptUseDES2:strDec key:@"12345678"];
            if (str) {
                isSelected = indexPath.row;
                [versionNoteArr addObject: str ];
                [tableViewForversion reloadData];
            }
            
        }else{
                strDec = [[versionInforArr objectAtIndex:indexPath.row-1] objectForKey:@"VersionNote"];
            
            NSString *str = [Mycrypt decryptWithText:strDec];
            //        NSString *str = [MyDesCrypt decryptUseDES2:strDec key:@"12345678"];
            if (str) {
                isSelected = indexPath.row-1;
                [versionNoteArr addObject: str ];
                [tableViewForversion reloadData];
            }
        }
        
    }
}



- (IBAction)comebackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
