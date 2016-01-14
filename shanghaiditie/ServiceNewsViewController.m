//
//  ServiceNewsViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "ServiceNewsViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "NewsTableViewCell.h"
#import "NewsDetailViewController.h"

@interface ServiceNewsViewController ()

@end

@implementation ServiceNewsViewController
@synthesize tableViewForNews;
@synthesize strFortitle;
@synthesize FirstdepartmentId;
@synthesize labelForTitle;
@synthesize delegate;
@synthesize tagNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tableViewForNews.delegate = self;
    tableViewForNews.dataSource = self;
    arrayForNews = [[NSMutableArray alloc]init];
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
    [tableViewForNews addSubview:refreshFooterView1];
    [self getNews:pageIndex pageSize:10];
    
    readNumber = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    labelForTitle.text = strFortitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////获取新闻列表
- (void)getNews:(NSInteger)pageindex pageSize:(NSInteger)pagesize
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 401;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"KYFW_NewsList_ByPage\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"PageSize\":\"%ld\",", (long)pagesize];    ////每页显示条数
    NSString *str4 = [NSString stringWithFormat:@"\"PageIndex\":\"%ld\",", (long)pageindex];  ////当前页数
    NSString *str5 = [NSString stringWithFormat:@"\"DepartmentId\":\"%@\"}",FirstdepartmentId];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
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
            [arrayForNews addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            for (int j=0, i =0; j<arrayForNews.count&&i<arrayForNews.count; j++ ,i++) {
                NSDictionary * dic = [[NSDictionary alloc]initWithDictionary:[arrayForNews objectAtIndex:i]];
                if ([[dic objectForKey:@"IsTop"] intValue] == 0) {
                    [arrayForNews addObject:dic];
                    [arrayForNews removeObjectAtIndex:0];
                    i--;
                }
            }
            totalPageNumber = [[[result objectForKey:@"Message"] objectForKey:@"totalCount"] intValue];
            [self addPullToRefreshFooter1];
            [tableViewForNews reloadData];
            
            [MBProgressHUD hideHUDForView:self.view];
        }
        else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"获取新闻列表失败，请检查网络！"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    return  arrayForNews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForNews objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"newsTableViewCell";
    NewsTableViewCell *cell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[NewsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ///cell恢复成最初状态
    cell.labelForNewsTitle.text = @"";
    cell.labelForNewsContent.text = @"";
    
    cell.labelForNewsTitle.text = [dic objectForKey:@"Title"];
    cell.labelForNewsContent.text = [dic objectForKey:@"Content"];
    if([[dic objectForKey:@"IsRead"] intValue] == 1)
    {
        cell.labelForNewsTitle.textColor = [UIColor grayColor];
        cell.labelForNewsContent.textColor = [UIColor grayColor];
    }else
    {
        cell.labelForNewsTitle.textColor = [UIColor redColor];
        cell.labelForNewsContent.textColor = [UIColor redColor];
    }
    
    for (int i=0; i<=arrayForImages.count; i++) {
        if (i==arrayForImages.count) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                NSData *imageDataForNews = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"LoginImageUrl"]]];
                NSDictionary * dicForimage = [[NSDictionary alloc]initWithObjectsAndKeys:imageDataForNews,@"imagedata", [dic objectForKey:@"NewsId"], @"newsid", nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [arrayForImages addObject:dicForimage];
                    cell.imageViewForNews.image = [UIImage imageWithData:imageDataForNews];
                });
                
            });
            break;
        }
        NSDictionary * dicimage = [arrayForImages objectAtIndex:i];
        if ([[dicimage objectForKey:@"newsid"] isEqualToString:[dic objectForKey:@"NewsId"]]) {
            cell.imageViewForNews.image = [UIImage imageWithData:[dicimage objectForKey:@"imagedata"]];
            break;
        }
    }
    
    
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell * cell = (NewsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.labelForNewsTitle.textColor = [UIColor grayColor];
    cell.labelForNewsContent.textColor = [UIColor grayColor];
    
    NSDictionary * dic = [arrayForNews objectAtIndex:indexPath.row];
    
    if([[dic objectForKey:@"IsRead"] intValue] == 0)
    {
        readNumber++;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NewsDetailViewController * newsDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"newsDetailViewController"];
    newsDetailViewController.dicForNews = [[NSDictionary alloc]initWithDictionary:dic];
    [self.navigationController pushViewController:newsDetailViewController animated:YES];
}

////添加加载等待页面
-(void)addPullToRefreshFooter1
{
    refreshFooterView1.frame = CGRectMake(0, 80*arrayForNews.count, 320, 45);
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
        tableViewForNews.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
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
    tableViewForNews.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
    refreshLabel1.text = @"正在加载⋯⋯";
    refreshImage1.hidden = YES;
    [refreshSpinner1 startAnimating];
    [UIView commitAnimations];
    // Refresh action!
    [self getNews:pageIndex pageSize:10];
}


- (IBAction)comeback:(id)sender {
    if (tagNumber != -1) {
        if (delegate) {
            [delegate showReadNumber:readNumber tag:tagNumber];
        }
    }
    readNumber=0;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
