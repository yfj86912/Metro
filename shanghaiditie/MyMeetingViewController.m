//
//  MyMeetingViewController.m
//  shanghaiditie
//
//  Created by yfj on 15/6/1.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MyMeetingViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "MyMeetingTableViewCell.h"
#import "MeetingDetailViewController.h"

@interface MyMeetingViewController ()
{
    NSMutableArray * arrayForMeeting;
    NSMutableArray * arrayForImages;
    
    int pageIndex;
    int totalPageNumber;
    int listNumber;
    //下拉刷新相关控件
    UILabel * refreshLabel1;
    UIImageView * refreshImage1;
    UIActivityIndicatorView * refreshSpinner1;    ///滑动刷新
    UIView * refreshFooterView1;
}

@end

@implementation MyMeetingViewController
@synthesize tableViewForMeeting;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的会议";
    
    tableViewForMeeting.delegate = self;
    tableViewForMeeting.dataSource = self;
    arrayForMeeting = [[NSMutableArray alloc]init];
    arrayForImages = [[NSMutableArray alloc]init];
    pageIndex = 0;
    ///添加刷新等待页面元素
    refreshFooterView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    refreshLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    refreshImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshImage1.alpha = 0;
    refreshImage1.frame = CGRectMake(0, 0, 1, 1);
    refreshSpinner1 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner1.frame = CGRectMake(0, 0, 1, 1);
    [refreshFooterView1 addSubview:refreshLabel1];
    [refreshFooterView1 addSubview:refreshImage1];
    [refreshFooterView1 addSubview:refreshSpinner1];
    [tableViewForMeeting addSubview:refreshFooterView1];
    [self getMeeting:pageIndex pageSize:10];
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

////获取我的会议列表
- (void)getMeeting:(NSInteger)pageindex pageSize:(NSInteger)pagesize
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
    request.tag = 401;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_HY_MeetingList_ByPage\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"PageSize\":\"%ld\",", (long)pagesize];    ////每页显示条数
    NSString *str4 = [NSString stringWithFormat:@"\"PageIndex\":\"%ld\",", (long)pageindex];  ////当前页数
    NSString *str5 = [NSString stringWithFormat:@"\"MeetingBeginDate\":\"\","];    ////每页显示条数
    NSString *str6 = [NSString stringWithFormat:@"\"MeetingEndDate\":\"\","];  ////当前页数
    NSString *str7 = [NSString stringWithFormat:@"\"SiteId\":\"\"}"];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str6 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str7 dataUsingEncoding:NSUTF8StringEncoding]];
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
    if(_request.tag == 401)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            pageIndex++;
            [arrayForMeeting addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            totalPageNumber = [[[result objectForKey:@"Message"] objectForKey:@"totalCount"] intValue];
            [self addPullToRefreshFooter1];
            [tableViewForMeeting reloadData];
            
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
    [MBProgressHUD showError:@"获取我的会议失败，请检查网络！"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrayForMeeting.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForMeeting objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"myMeetingTableViewCell";
    MyMeetingTableViewCell *cell = (MyMeetingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[MyMeetingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ///cell恢复成最初状态
    cell.labelForMeetingName.text = @"";
    cell.labelForMeetingTime.text = @"";
    
    cell.labelForMeetingName.text = [dic objectForKey:@"MeetingName"];
    cell.labelForMeetingTime.text = [dic objectForKey:@"MeetingBeginDate"];
    cell.labelForStatu.alpha = 0;
    
//    for (int i=0; i<=arrayForImages.count; i++) {
//        if (i==arrayForImages.count) {
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            dispatch_async(queue, ^{
//                NSData *imageDataForNews = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"LoginImageUrl"]]];
//                NSDictionary * dicForimage = [[NSDictionary alloc]initWithObjectsAndKeys:imageDataForNews,@"imagedata", [dic objectForKey:@"NewsId"], @"newsid", nil];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [arrayForImages addObject:dicForimage];
//                    cell.imageViewForPic.image = [UIImage imageWithData:imageDataForNews];
//                });
//                
//            });
//            break;
//        }
//        NSDictionary * dicimage = [arrayForImages objectAtIndex:i];
//        if ([[dicimage objectForKey:@"newsid"] isEqualToString:[dic objectForKey:@"NewsId"]]) {
//            cell.imageViewForPic.image = [UIImage imageWithData:[dicimage objectForKey:@"imagedata"]];
//            break;
//        }
//    }
    
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForMeeting objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MeetingDetailViewController * meetingDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingDetailViewController"];
//    meetingDetailViewController.strForMeetingId = [[NSString alloc]initWithString:[dic objectForKey:@"Id"]];
    meetingDetailViewController.strForMeetingId = [[NSString alloc]initWithString:[dic objectForKey:@"Id"]];

    [self.navigationController pushViewController:meetingDetailViewController animated:YES];
}

////添加加载等待页面
-(void)addPullToRefreshFooter1
{
    refreshFooterView1.frame = CGRectMake(0, 80*arrayForMeeting.count, 320, 45);
    refreshFooterView1.backgroundColor = [UIColor clearColor];
    
    refreshLabel1.frame = CGRectMake(0, 0, 320, 45);
    refreshLabel1.backgroundColor = [UIColor clearColor];
    refreshLabel1.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel1.textAlignment = NSTextAlignmentCenter;
    
    refreshImage1.frame = CGRectMake(floorf((45 - 27) / 2),
                                     (floorf(45 - 44) / 2),
                                     27, 44);
    
    refreshSpinner1.frame = CGRectMake(floorf(floorf(45 - 20) / 2), floorf((45 - 20) / 2), 20, 20);
    refreshSpinner1.hidesWhenStopped = YES;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (pageIndex*10<=totalPageNumber && scrollView.contentOffset.y > 0) {
        tableViewForMeeting.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    }
    else if(pageIndex*10 > totalPageNumber)
    {
        refreshLabel1.text = @"没有更多内容了！";
        refreshImage1.hidden = YES;
        [refreshSpinner1 stopAnimating];
    }
    else if (pageIndex*10<=totalPageNumber  && (scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom)) <= 0)
    {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        refreshImage1.hidden = NO;
        if (scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -45) {
            // User is scrolling above the header
            refreshLabel1.text = @"释放开始刷新...";
            [refreshImage1 layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel1.text = @"上拉刷新...";
            [refreshImage1 layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (pageIndex*10>totalPageNumber) return;
    //上拉刷新
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -45 && scrollView.contentOffset.y > 0){
        [self startLoading];
    }
    
}

- (void)startLoading {
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    tableViewForMeeting.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
    refreshLabel1.text = @"正在加载⋯⋯";
    refreshImage1.hidden = YES;
    [refreshSpinner1 startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self getMeeting:pageIndex pageSize:10];
    
    
}



- (IBAction)comeBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
