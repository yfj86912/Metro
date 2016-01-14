//
//  SalaryInfoViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/12.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "SalaryInfoViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "SalaryDetailInfoTableViewCell.h"
#import "SalaryInfoTableViewCell.h"

@interface SalaryInfoViewController ()

@end

@implementation SalaryInfoViewController
@synthesize labelForCompany, labelForPart, labelForStation, labelForUserName, imageViewForHead;
@synthesize tableViewForSalary;
@synthesize choosemonth, chooseYear;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrayForSalary = [[NSMutableArray alloc]init];
    tableViewForSalary.delegate = self;
    tableViewForSalary.dataSource = self;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString * str = [d objectForKey:@"LoginImgUrl"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *imageDataForNews = [NSData dataWithContentsOfURL:[NSURL URLWithString:[d objectForKey:@"LoginImgUrl"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageViewForHead.layer.masksToBounds = YES;
            imageViewForHead.layer.cornerRadius = 10;
            imageViewForHead.image = [UIImage imageWithData:imageDataForNews];
        });
    });
    
    labelForUserName.text = [d objectForKey:@"FullName"];
    labelForCompany.text = [d objectForKey:@"CompanyName"];
    labelForStation.text = [d objectForKey:@"PostName"];
    labelForPart.text = [d objectForKey:@"DepartmentName"];
    
    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *comp1 = [myCal components:units fromDate:now];
    nowmonth = (int)[comp1 month];
    nowyear = (int)[comp1 year];
    isChange = YES;
    
    if (chooseYear>0) {
        if (chooseYear!=nowyear) {
            [self getNews:chooseYear month:choosemonth];
            isChange = NO;
        }else{
            [self getNews:chooseYear month:choosemonth];
            isChange = YES;
        }
        
    }else{
        choosemonth = nowmonth;
        [self getNews:nowyear month:nowmonth];
    }
    
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

////获取用户个人财务
- (void)getNews:(NSInteger)year month:(NSInteger)month
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, jhcw];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 501;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"JHCW_FinanceInfo\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"Year\":%ld,", (long)year];
    NSString *str4 = [NSString stringWithFormat:@"\"Month\":%ld}", (long)month];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
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
    if(_request.tag == 501)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [arrayForSalary removeAllObjects];
            [arrayForSalary addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            [tableViewForSalary reloadData];
            [MBProgressHUD hideHUDForView:self.view];
        }
        else if ([[result objectForKey:@"State"] isEqualToString:@"Error"]) {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
        else if([[result objectForKey:@"State"] isEqualToString:@"None"]){
            [arrayForSalary removeAllObjects];
            [tableViewForSalary reloadData];
            [MBProgressHUD hideHUDForView:self.view];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"获取个人财务信息失败，请检查网络！"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isChange) {
        if (indexPath.row == 0) {
            return 333;
        }else{
            return 44;
        }
    }else{
        if (indexPath.row == 0) {
            return 44;
        }else{
            return 333;
        }
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isChange) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"salaryDetailInfoTableViewCell";
            SalaryDetailInfoTableViewCell *cell = (SalaryDetailInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell=[[SalaryDetailInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            for (UIButton * btn in cell.scrollViewForMonth.subviews) {
                [btn removeFromSuperview];
            }
            
            for (int i=1; i<=nowmonth; i++) {
                UIButton *btnFormonth = [UIButton buttonWithType:UIButtonTypeCustom];
                [btnFormonth setTitle:[NSString stringWithFormat:@"%d月",i] forState:UIControlStateNormal];
                btnFormonth.frame = CGRectMake(10+58*(i-1), 2, 48, 48);
                btnFormonth.titleLabel.font = [UIFont systemFontOfSize:12];
                btnFormonth.tag = i;
                [btnFormonth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btnFormonth addTarget:self action:@selector(getMonthSalary:) forControlEvents:UIControlEventTouchUpInside];
                if (i== choosemonth) {
                    [btnFormonth setTitleColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1] forState:UIControlStateNormal];
                }
                [cell.scrollViewForMonth addSubview:btnFormonth];
                
            }
            cell.scrollViewForMonth.contentSize = CGSizeMake(nowmonth*58+10, 52);
            
            for (UILabel * lab in cell.scrollViewForSalary.subviews) {
                [lab removeFromSuperview];
            }
            if (arrayForSalary.count==0) {
                UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, 280, 34)];
                label1.text = @"无当月工资信息！";
                label1.font = [UIFont systemFontOfSize:18];
                label1.textAlignment = NSTextAlignmentCenter;
                [cell.scrollViewForSalary addSubview:label1];
                
            }else{
                for (int j =0; j<arrayForSalary.count; j++) {
                    NSDictionary * dic = [arrayForSalary objectAtIndex:j];
                    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(10+(j%2)*150, 10+(j/2)*30, 150, 20)];
                    label1.text = [NSString stringWithFormat:@"%@:%@", [dic objectForKey:@"TypeName"],[dic objectForKey:@"GongZiCount"]];
                    label1.font = [UIFont systemFontOfSize:15];
                    [cell.scrollViewForSalary addSubview:label1];
                }
                cell.scrollViewForSalary.contentSize = CGSizeMake(cell.scrollViewForSalary.frame.size.width, 10+(arrayForSalary.count/2+arrayForSalary.count%2)*30);
            }
            
            cell.labelForTime.text = [NSString stringWithFormat:@"%d年%d月工资",nowyear, choosemonth];
            return cell;
        }else{
            static NSString *CellIdentifier = @"salaryInfoTableViewCell";
            SalaryInfoTableViewCell *cell = (SalaryInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell=[[SalaryInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.labelForYear.text = [NSString stringWithFormat:@"%d年工资", nowyear-1];
            return cell;
        }
    }else{
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"salaryInfoTableViewCell";
            SalaryInfoTableViewCell *cell = (SalaryInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell=[[SalaryInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.labelForYear.text = [NSString stringWithFormat:@"%d年工资", nowyear];
            return cell;
        }else{
            static NSString *CellIdentifier = @"salaryDetailInfoTableViewCell";
            SalaryDetailInfoTableViewCell *cell = (SalaryDetailInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell=[[SalaryDetailInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            for (UIButton * btn in cell.scrollViewForMonth.subviews) {
                [btn removeFromSuperview];
            }
            
            for (int i=1; i<=12; i++) {
                UIButton *btnFormonth = [UIButton buttonWithType:UIButtonTypeCustom];
                [btnFormonth setTitle:[NSString stringWithFormat:@"%d月",i] forState:UIControlStateNormal];
                btnFormonth.frame = CGRectMake(10+58*(i-1), 2, 48, 48);
                btnFormonth.titleLabel.font = [UIFont systemFontOfSize:12];
                btnFormonth.tag = i;
                [btnFormonth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btnFormonth addTarget:self action:@selector(getMonthSalary:) forControlEvents:UIControlEventTouchUpInside];
                if (i== choosemonth) {
                    [btnFormonth setTitleColor:[UIColor colorWithRed:57/255.0 green:178/255.0 blue:50/255.0 alpha:1] forState:UIControlStateNormal];
                }
                [cell.scrollViewForMonth addSubview:btnFormonth];
            }
            cell.scrollViewForMonth.contentSize = CGSizeMake(12*58+10, 52);
            
            for (UILabel * lab in cell.scrollViewForSalary.subviews) {
                [lab removeFromSuperview];
            }
            if (arrayForSalary.count==0) {
                UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, 280, 34)];
                label1.text = @"无当月工资信息！";
                label1.font = [UIFont systemFontOfSize:18];
                label1.textAlignment = NSTextAlignmentCenter;
                [cell.scrollViewForSalary addSubview:label1];
                
            }else{
                for (int j =0; j<arrayForSalary.count; j++) {
                    NSDictionary * dic = [arrayForSalary objectAtIndex:j];
                    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(10+(j%2)*150, 10+(j/2)*30, 150, 20)];
                    label1.text = [NSString stringWithFormat:@"%@:%@", [dic objectForKey:@"TypeName"],[dic objectForKey:@"GongZiCount"]];
                    label1.font = [UIFont systemFontOfSize:15];
                    [cell.scrollViewForSalary addSubview:label1];
                }
                cell.scrollViewForSalary.contentSize = CGSizeMake(cell.scrollViewForSalary.frame.size.width, 10+(arrayForSalary.count/2+arrayForSalary.count%2)*30);
            }
            
            
            cell.labelForTime.text = [NSString stringWithFormat:@"%d年%d月工资",nowyear-1, choosemonth];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isChange && indexPath.row == 0) {
        isChange = YES;
        choosemonth = 1;
        [self getNews:nowyear month:choosemonth];
    }
    if (isChange && indexPath.row == 1) {
        isChange = NO;
        choosemonth = 1;
        [self getNews:nowyear-1 month:choosemonth];
    }
    
}

-(IBAction)getMonthSalary:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    choosemonth = (int )btn.tag;
    if (isChange) {
        [self getNews:nowyear month:btn.tag];
    }else{
        [self getNews:nowyear-1 month:btn.tag];
    }
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
