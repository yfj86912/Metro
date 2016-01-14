//
//  FileListViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "FileListViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "FileDetailViewController.h"
#import "FileTableViewCell.h"

@interface FileListViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * arrayForFile;
    
    int pageIndex;
    int totalPageNumber;
    int listNumber;
    //下拉刷新相关控件
    UILabel * refreshLabel1;
    UIImageView * refreshImage1;
    UIActivityIndicatorView * refreshSpinner1;    ///滑动刷新
    UIView * refreshFooterView1;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewForFile;
@property (weak, nonatomic) IBOutlet UITextField * textFieldForFile;
@property (weak, nonatomic) IBOutlet UIButton * btnForSearch;

- (IBAction)comeback:(id)sender;
@end

@implementation FileListViewController
@synthesize tableViewForFile;
@synthesize textFieldForFile, btnForSearch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableViewForFile.delegate  = self;
    tableViewForFile.dataSource = self;
    
    arrayForFile = [[NSMutableArray alloc]init];
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
    [tableViewForFile addSubview:refreshFooterView1];
    [self getFile:pageIndex pageSize:10];
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

////获取我的文件列表
- (void)getFile:(NSInteger)pageindex pageSize:(NSInteger)pagesize
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
    request.tag = 1401;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"BGS_WJ_FileList_ByPage\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"PageSize\":\"%ld\",", (long)pagesize];    ////每页显示条数
    NSString *str4 = [NSString stringWithFormat:@"\"PageIndex\":\"%ld\",", (long)pageindex];  ////当前页数
    NSString *str5 = [NSString stringWithFormat:@"\"CompanyId\":\"%@\",", [d objectForKey:@"CompanyId"]];
    NSString *str6 = [NSString stringWithFormat:@"\"DepartmentId\":\"%@\"}", [d objectForKey:@"DepartmentId"]];
    
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

////搜索文件信息
-(IBAction)actionForSearchFile:(id)sender
{
    pageIndex = 0;
    [arrayForFile removeAllObjects];
    [self getFile:pageIndex pageSize:10];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 1401)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            pageIndex++;
            [arrayForFile addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            totalPageNumber = [[[result objectForKey:@"Message"] objectForKey:@"totalCount"] intValue];
            [self addPullToRefreshFooter1];
            [tableViewForFile reloadData];
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
    [MBProgressHUD showError:@"获取会议列表失败，请检查网络！"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrayForFile.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForFile objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"fileTableViewCell";
    FileTableViewCell *cell = (FileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[FileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ///cell恢复成最初状态
    cell.fileName.text = @"";
    
    cell.fileName.text = [dic objectForKey:@"FileName"];
    cell.labelForFileKind.text = [dic objectForKey:@"FileType"];
    cell.labelForFileTime.text = [dic objectForKey:@"CreateDate"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrayForFile objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    FileDetailViewController * fileDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"fileDetailViewController"];
    fileDetailViewController.dicForFile = [[NSDictionary alloc]initWithDictionary:dic];
    fileDetailViewController.strForFileId = [dic objectForKey:@"Id"];
    fileDetailViewController.url = [dic objectForKey:@"FileImageUrl"];
    [self.navigationController pushViewController:fileDetailViewController animated:YES];
}

////添加加载等待页面
-(void)addPullToRefreshFooter1
{
    refreshFooterView1.frame = CGRectMake(0, 80*arrayForFile.count, 320, 45);
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
        tableViewForFile.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
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
    tableViewForFile.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
    refreshLabel1.text = @"正在加载⋯⋯";
    refreshImage1.hidden = YES;
    [refreshSpinner1 startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self getFile:pageIndex pageSize:10];
    
    
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
