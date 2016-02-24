//
//  FileSeachViewController.m
//  shanghaiditie
//
//  Created by winter on 16/1/28.
//  Copyright © 2016年 21k. All rights reserved.
//

#import "FileSeachViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "MetroFileTableViewCell.h"
#import "ShowPDFViewController.h"

@interface FileSeachViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIDocumentInteractionControllerDelegate>
{
    NSMutableArray * arrayFortoptab;
    NSMutableArray * arrayForFile;
    NSMutableArray * arrayForComplete;
    UIView * viewForComplete;
    UITableView * tableViewForComplete;
    
    UIView * viewForKind;
    int searchTypeId;
    NSString * typeId;
    UIDocumentInteractionController * fileInteractionController;
    
    int pageIndex;
    int totalPageNumber;
    int listNumber;

    //下拉刷新相关控件
    UILabel * refreshLabel1;
    UIImageView * refreshImage1;
    UIActivityIndicatorView * refreshSpinner1;    ///滑动刷新
    UIView * refreshFooterView1;
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnForkind;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewFortoptab;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForFile;
@property (weak, nonatomic) IBOutlet UITextField * textFieldForFile;
@property (weak, nonatomic) IBOutlet UIButton * btnForSearch;
@property (nonatomic, strong) NSString * strForSearchKey;
@property (weak, nonatomic) IBOutlet UIImageView *imageviewback;
- (IBAction)actionForKind:(id)sender;

- (IBAction)comeback:(id)sender;

@end

@implementation FileSeachViewController
@synthesize witchFile;
@synthesize scrollViewFortoptab, tableViewForFile, textFieldForFile, btnForSearch;
@synthesize strForSearchKey;
@synthesize btnForkind;
@synthesize imageviewback;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrayForFile = [[NSMutableArray alloc]init];
    arrayFortoptab = [[NSMutableArray alloc]init];
    arrayForComplete = [[NSMutableArray alloc]init];
    pageIndex = 0;
    searchTypeId = 0;
    
    tableViewForFile.delegate = self;
    tableViewForFile.dataSource = self;
    
    textFieldForFile.delegate = self;
    textFieldForFile.text = @"";
    textFieldForFile.returnKeyType = UIReturnKeyDone;
    
    [self addView];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getFileType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//textfieldDelegate--
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![string isEqualToString:@""]) {
        [self fileNameComplete];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) addView
{
    CALayer * layer = [imageviewback layer];
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 0.5f;
    
    viewForKind = [[UIView alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(btnForkind.frame), 46, 90)];
    [viewForKind setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewForKind];
    
    UIFont* font = [UIFont systemFontOfSize:15.0];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.tag = 20000;
    [btn1 setFrame:CGRectMake(0, 0, 46, 30)];
    btn1.titleLabel.font = font;
    [btn1 setTitle:@"全部" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(chooseKind:) forControlEvents:UIControlEventTouchUpInside];
    [viewForKind addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.tag = 20001;
    [btn2 setFrame:CGRectMake(0, 30, 46, 30)];
    btn2.titleLabel.font = font;
    [btn2 setTitle:@"专业" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(chooseKind:) forControlEvents:UIControlEventTouchUpInside];
    [viewForKind addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.tag = 20002;
    [btn3 setFrame:CGRectMake(0, 60, 46, 30)];
    btn3.titleLabel.font = font;
    [btn3 setTitle:@"岗位" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(chooseKind:) forControlEvents:UIControlEventTouchUpInside];
    [viewForKind addSubview:btn3];
    
    viewForKind.alpha = 0;
}

- (void) addCompleteView
{
    int heightForView;
    if (arrayForComplete.count>5) {
        heightForView = 150;
    }else{
        heightForView = (int)arrayForComplete.count*30;
    }
    if (!viewForComplete) {
        
        viewForComplete = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(textFieldForFile.frame), [UIScreen mainScreen].bounds.size.width, heightForView)];
        [viewForComplete setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:viewForComplete];
        
        CALayer * layer = [viewForComplete layer];
        layer.borderColor = [[UIColor grayColor] CGColor];
        layer.borderWidth = 0.5f;
        
        tableViewForComplete = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, viewForComplete.frame.size.width, viewForComplete.frame.size.height)];
        tableViewForComplete.dataSource = self;
        tableViewForComplete.delegate = self;
        tableViewForComplete.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [viewForComplete addSubview:tableViewForComplete];
    }else
    {
        viewForComplete.alpha = 1;
        viewForComplete.frame = CGRectMake(0, CGRectGetMaxY(textFieldForFile.frame), [UIScreen mainScreen].bounds.size.width, heightForView);
        tableViewForComplete.frame = CGRectMake(0, 0, viewForComplete.frame.size.width, viewForComplete.frame.size.height);
        [tableViewForComplete reloadData];
    }
    
    
}


-(IBAction)chooseKind:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    searchTypeId = (int)btn.tag-20000;
    switch (searchTypeId) {
        case 0:
            [btnForkind setTitle:@"全部" forState:UIControlStateNormal];
            break;
        case 1:
            [btnForkind setTitle:@"专业" forState:UIControlStateNormal];
            break;
        case 2:
            [btnForkind setTitle:@"岗位" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    btnForkind.selected = NO;
    viewForKind.alpha = 0;
}



////获取分类
- (void)getFileType
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, Fil];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1801;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"File_TypeList\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"ModalTypeId\":\"%d\"}", witchFile];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

////文件名自动补全接口
- (void)fileNameComplete
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, Fil];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1802;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"File_List_ByComplete\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"ModalTypeId\":\"%d\",", witchFile];
    NSString *str4 = [NSString stringWithFormat:@"\"SearchKey\":\"%@\",", textFieldForFile.text];
    NSString *str5 = [NSString stringWithFormat:@"\"TypeId\":\"%@\",", typeId];
    NSString *str6 = [NSString stringWithFormat:@"\"SearchTypeId\":\"%d\"}", searchTypeId];
    
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



////获取我的文件列表
- (void)getFile:(NSInteger)pageindex pageSize:(NSInteger)pagesize
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, Fil];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1803;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"File_List_ByPage\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"PageSize\":\"%ld\",", (long)pagesize];    ////每页显示条数
    NSString *str4 = [NSString stringWithFormat:@"\"PageIndex\":\"%ld\",", (long)pageindex];  ////当前页数
    NSString *str5 = [NSString stringWithFormat:@"\"ModalTypeId\":\"%d\",", witchFile];
    NSString *str6 = [NSString stringWithFormat:@"\"SearchKey\":\"%@\",", textFieldForFile.text];
    NSString *str7 = [NSString stringWithFormat:@"\"TypeId\":\"%@\",", typeId];
    NSString *str8 = [NSString stringWithFormat:@"\"SearchTypeId\":\"%d\"}", searchTypeId];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str6 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str7 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str8 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

////搜索文件信息
-(IBAction)actionForSearchFile:(id)sender
{
    viewForComplete.alpha = 0;
    pageIndex = 1;
    [arrayForFile removeAllObjects];
    [self getFile:pageIndex pageSize:10];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 1801)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            [arrayFortoptab removeAllObjects];
            [arrayFortoptab addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            if(arrayFortoptab.count>0){
                [self setscrollViewBtn];
                [arrayForFile removeAllObjects];
                [MBProgressHUD hideHUDForView:self.view];
                [self getFile:1 pageSize:10];
            }else
            [MBProgressHUD hideHUDForView:self.view];
            
        }else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }else if(_request.tag == 1802){
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            if ([[[result objectForKey:@"Message"] objectForKey:@"count"] intValue]==0) {
                return;
            }
            [arrayForComplete removeAllObjects];
            [arrayForComplete addObjectsFromArray:[[result objectForKey:@"Message"] objectForKey:@"rows"]];
            [self addCompleteView];
        }
        
    }else if(_request.tag == 1803){
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
    [MBProgressHUD showError:@""];
}

- (void)setscrollViewBtn
{
    int Xmax = 5;
    for (int i=0; i<arrayFortoptab.count; i++) {
        NSDictionary * dicFortoptab = [arrayFortoptab objectAtIndex:i];
        NSString * title = [dicFortoptab objectForKey:@"TypeName"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIFont* font = [UIFont systemFontOfSize:15.0];
        //    CGFloat width = [title sizeWithFont:font].width+kNaviItemMargin*2;
        CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName:font}].width+5*2;
        [button setFrame:CGRectMake(Xmax, 0, width, 44)];
        button.tag = 30000+i;
        button.titleLabel.font = font;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        if (i==0) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(chooseTypeId:) forControlEvents:UIControlEventTouchUpInside];
        [scrollViewFortoptab addSubview:button];
        Xmax = width+Xmax+5;
    }
    NSDictionary * dicFortoptab = [arrayFortoptab objectAtIndex:0];
    typeId = [dicFortoptab objectForKey:@"Id"];
    
    [scrollViewFortoptab setContentSize:CGSizeMake(Xmax, 44)];
    
}

- (IBAction)chooseTypeId:(id)sender
{
    for (id button in scrollViewFortoptab.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    UIButton * btn = (UIButton *)sender;
    NSDictionary * dicFortoptab = [arrayFortoptab objectAtIndex:btn.tag-30000];
    typeId = [dicFortoptab objectForKey:@"Id"];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [arrayForFile removeAllObjects];
    [self getFile:1 pageSize:10];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableViewForComplete == tableView) {
        return 30;
    }else{
        return 60;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableViewForComplete == tableView) {
        return arrayForComplete.count;
    }
    return  arrayForFile.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableViewForComplete == tableView) {
        NSDictionary * dic = [arrayForComplete objectAtIndex:indexPath.row];
        
        static NSString *CellIdentifier = @"TableViewCell";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        ///cell恢复成最初状态
        cell.textLabel.text = [dic objectForKey:@"FileName"];
        
        return cell;
    }
    
    NSDictionary * dic = [arrayForFile objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"metroFileTableViewCell";
    MetroFileTableViewCell *cell = (MetroFileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[MetroFileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ///cell恢复成最初状态
    cell.labelForfileName.text = [dic objectForKey:@"FileName"];
    cell.labelForFileZhuanYe.text = [dic objectForKey:@"FileZhuanYe"];
    cell.labelForFileGangWei.text = [dic objectForKey:@"FileGangWei"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableViewForComplete == tableView) {
        NSDictionary * dic = [arrayForComplete objectAtIndex:indexPath.row];
        textFieldForFile.text = [dic objectForKey:@"FileName"];
        viewForComplete.alpha = 0;
    }else{
        NSDictionary * dic = [arrayForFile objectAtIndex:indexPath.row];
        NSString * fileurl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"FileUrl"]];
        NSString * fileId = [dic objectForKey:@"Id"];
        [self showwebview:fileurl fileId:fileId];
    }
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


- (IBAction)actionForKind:(id)sender {
    UIButton * btn = (UIButton *)sender;
    if (!btn.selected) {
        viewForKind.alpha = 1;
    }else{
        viewForKind.alpha = 0;
    }
    btn.selected = !btn.selected;
}

- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showwebview:(NSString *)strForUrl fileId:(NSString *)strForFileId
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ShowPDFViewController * showPDFViewController = [storyboard instantiateViewControllerWithIdentifier:@"showPDFViewController"];
    showPDFViewController.url = strForUrl;
    showPDFViewController.fileId = strForFileId;
    [self.navigationController pushViewController:showPDFViewController animated:YES];
}




#pragma 文件下载 存储 ---
- (void)actionForDownloadFile:(NSString *)strForUrl filename:(NSString *)saveFileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fileFolder"]; //path的路径一般为/Users/apple/Library/Application Support/iPhone Simulator/5.0/Applications/3DDEC2C9-6BBC-48F3-95A9-C69FE2CC9409/Documents
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"创建文件夹失败: %@", error);
        }
    }
    
    NSString *filepath = [path stringByAppendingPathComponent:saveFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSURL *url=[NSURL URLWithString:strForUrl];
        NSURLRequest *request=[NSURLRequest requestWithURL:url];
        NSError *downloaderror=nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&downloaderror];
        if([data length]>0)
        {
            NSLog(@"下载成功");
            if([data writeToFile:filepath atomically:YES]){
                [self openFile:filepath];
                NSLog(@"保存成功");
            }else{
                NSLog(@"保存失败");
            }
        }
        else
        {
            NSLog(@"下载失败，失败原因：%@",error);
        }
    }

}

//用第三方应用打开文件
- (void)openFile: (NSString *)strForFile {
    NSURL *file_URL = [NSURL fileURLWithPath:strForFile];
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path]) {
        if (fileInteractionController == nil) {
            fileInteractionController = [[UIDocumentInteractionController alloc] init];
            fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
            fileInteractionController.delegate = self;
        }else {
            fileInteractionController.URL = file_URL;
        }
        [fileInteractionController presentPreviewAnimated:YES];
//    }
}

@end
