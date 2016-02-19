//
//  ShowPDFViewController.m
//  shanghaiditie
//
//  Created by winter on 16/2/4.
//  Copyright © 2016年 21k. All rights reserved.
//

#import "ShowPDFViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface ShowPDFViewController ()<UIDocumentInteractionControllerDelegate>
{
    NSString * fileDownloadUrl;
    UIDocumentInteractionController * fileInteractionController;
}

@property (weak, nonatomic) IBOutlet UIButton *btnForDownload;
- (IBAction)actionForDownload:(id)sender;
@end

@implementation ShowPDFViewController
@synthesize url,fileId;
@synthesize btnForDownload;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    [self.view addSubview:webView];
    NSURL *urlR=[NSURL URLWithString:url];
    NSURLRequest *request=[NSURLRequest requestWithURL:urlR];
    [webView loadRequest:request];
    if ([self isHaveFile]) {
        [btnForDownload setTitle:@"打印" forState:UIControlStateNormal];
    }else{
        [btnForDownload setEnabled:NO];
        [self getFileUrl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//判断文件是否存在
- (BOOL)isHaveFile
{
    NSString *filename = [NSString stringWithFormat:@"%@.pdf",fileId];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename]; //path的路径一般为/Users/apple/Library/Application Support/iPhone Simulator/5.0/Applications/3DDEC2C9-6BBC-48F3-95A9-C69FE2CC9409/Documents
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])    //Does directory already exist?
    {
        return NO;
    }else{
        return YES;
    }
}

////获取下载文件URL
- (void)getFileUrl
{
    [MBProgressHUD showMessage:nil toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, Fil];
    NSURL *urladd=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:urladd];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 1901;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"GetFileDownLoadUrl\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"FileId\":\"%@\"}", fileId];
    
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
    if(_request.tag == 1901)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            fileDownloadUrl = [[result objectForKey:@"Message"] objectForKey:@"FileDownLoadUrl"];
            if (![fileDownloadUrl isEqualToString:@""] && fileDownloadUrl!=nil) {
                [btnForDownload setEnabled:YES];
            }
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



//  webviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


-(void)back
{
    if ([webView canGoBack]) {
        [webView goBack];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)actionForDownload:(id)sender {
    if([btnForDownload.titleLabel.text isEqualToString:@"打印"])
    {
        NSString *filename = [NSString stringWithFormat:@"%@.pdf",fileId];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        NSURL *file_URL = [NSURL fileURLWithPath:path];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            if (fileInteractionController == nil) {
                fileInteractionController = [[UIDocumentInteractionController alloc] init];
                fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
                fileInteractionController.delegate = self;
            }else {
                fileInteractionController.URL = file_URL;
            }
            [fileInteractionController presentPreviewAnimated:YES];
        }
        
            
    }else{
        if ([self downloadFile]) {
            [btnForDownload setTitle:@"打印" forState:UIControlStateNormal];
            [MBProgressHUD showSuccess:@"下载文件成功"];
        }else{
            [MBProgressHUD showError:@"下载文件失败 ，请重试！"];
        }
    }
}


//下载文件
-(BOOL)downloadFile
{
    NSString *filename = [NSString stringWithFormat:@"%@.pdf",fileId];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    NSURL *urlForFile=[NSURL URLWithString:fileDownloadUrl];
    NSURLRequest *request=[NSURLRequest requestWithURL:urlForFile];
    NSError *error=nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if([data length]>0)
    {
        NSLog(@"下载成功");
        if([data writeToFile:path atomically:YES]){
            NSLog(@"保存成功");
            return YES;
        }
        else{
            NSLog(@"保存失败");
            return NO;
        }
        
    }
    else
    {
        NSLog(@"下载失败，失败原因：%@",error);
        return NO;
    }
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"documentInteractionControllerDidEndPreview");
}
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
}

@end
