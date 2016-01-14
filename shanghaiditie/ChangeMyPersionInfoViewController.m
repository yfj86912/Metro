//
//  ChangeMyPersionInfoViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/5/25.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "ChangeMyPersionInfoViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import <AVFoundation/AVFoundation.h>
#import "Mycrypt.h"
#import "MyDesCrypt.h"

@interface ChangeMyPersionInfoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ChangeMyPersionInfoViewController
@synthesize labelForName, labelForPart, labelForStation, LabelForEmail, textFieldForPhone, textFieldForSex, textViewFordes,imageViewForHead, imageViewForChangeHead, companyName, btnFortextViewOK;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    textFieldForSex.delegate = self;
    textFieldForSex.tag = 101;
    textFieldForPhone.delegate =self;
    textFieldForPhone.tag = 102;
    textFieldForPhone.returnKeyType = UIReturnKeyDone;
    textViewFordes.delegate = self;
    btnFortextViewOK.alpha = 0;
    changeOK = NO;
    [self getUserInfo];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    viewForSex = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(textFieldForSex.frame), CGRectGetMaxY(textFieldForSex.frame), CGRectGetWidth(textFieldForSex.frame), (CGRectGetHeight(textFieldForSex.frame)+10)*2)];
    viewForSex.layer.cornerRadius = 3;
    viewForSex.layer.masksToBounds = YES;
    [viewForSex setBackgroundColor:[UIColor colorWithRed:244/255.0 green:243/255.0 blue:244/255.0 alpha:1]];
    [self.view addSubview:viewForSex];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"男" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn1.frame = CGRectMake(2, 2, viewForSex.frame.size.width-4, CGRectGetHeight(textFieldForSex.frame)+6);
    btn1.tag = 10000;
    [btn1 addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
    btn1.layer.cornerRadius = 3;
    btn1.layer.masksToBounds = YES;
    [viewForSex addSubview:btn1];
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"女" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn2.frame = CGRectMake(2, CGRectGetHeight(textFieldForSex.frame)+14, viewForSex.frame.size.width-4, CGRectGetHeight(textFieldForSex.frame)+6);
    btn2.tag = 20000;
    [btn2 addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius = 3;
    btn2.layer.masksToBounds = YES;
    [viewForSex addSubview:btn2];
    viewForSex.alpha = 0;
}

-(IBAction)chooseSex:(id)sender
{
    int choose = ((UIButton *)sender).tag;
    switch (choose) {
        case 10000:
            textFieldForSex.text = @"男";
            break;
        case 20000:
            textFieldForSex.text = @"女";
            break;
        default:
            break;
    }
    viewForSex.alpha = 0;
    
}

-(void)reFresh
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString * str = [d objectForKey:@"LoginImgUrl"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *imageDataForNews = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageViewForHead.layer.masksToBounds = YES;
            imageViewForHead.layer.cornerRadius = 30;
            imageViewForHead.image = [UIImage imageWithData:imageDataForNews];
        });
    });
    
    imageViewForChangeHead.layer.masksToBounds = YES;
    imageViewForChangeHead.layer.cornerRadius = 20;
    
    labelForName.text = [d objectForKey:@"FullName"];
    companyName.text = [d objectForKey:@"CompanyName"];
    labelForStation.text = [d objectForKey:@"PostName"];
    labelForPart.text = [d objectForKey:@"DepartmentName"];
    LabelForEmail.text = [d objectForKey:@"Email"];
    textFieldForSex.text = [d objectForKey:@"Sex"];
    textFieldForPhone.text = [d objectForKey:@"PhoneNumber"];
    textViewFordes.text = [d objectForKey:@"Signature"];
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

#pragma mark --键盘遮挡代理
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 101:
        {
//            [textField resignFirstResponder];
//            [UIView animateWithDuration:0.3f animations:^{
//                viewForSex.alpha = 1;
//            }];
        }
            break;
        case 102:
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self.view setFrame:CGRectMake(0, -60, self.view.bounds.size.width, self.view.bounds.size.height)];
            }];
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    switch (textField.tag) {
        case 101:
        {
            [textField resignFirstResponder];
            [textFieldForPhone resignFirstResponder];
            [textViewFordes resignFirstResponder];
            [UIView animateWithDuration:0.3f animations:^{
                viewForSex.alpha = 1;
            }];
        }
            break;
        default:
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==textFieldForPhone && textField.text.length>=11 && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    float height = [[UIApplication sharedApplication] keyWindow].frame.size.height - 700;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0, -200, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
    btnFortextViewOK.alpha = 1;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textViewFordes resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
}

- (IBAction)actionForHideKeyboard:(id)sender {
    [textViewFordes resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
}

- (IBAction)actionForChangeHead:(id)sender {
    NSLog(@"头像");
    //判断相机是否授权
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized 已经授权
        
        NSLog(@"照相机");
        UIActionSheet *sheet;
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            sheet = [[UIActionSheet alloc]initWithTitle:@"选取头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
        }else{
            
            sheet = [[UIActionSheet alloc]initWithTitle:@"选取头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
        }
        sheet.tag = 301;
        [sheet showInView:self.view];
        
    }else if (status == AVAuthorizationStatusNotDetermined){//第一次使用，则会弹出是否打开权限
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {//点击允许访问时调用
                 //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                 // 相机
                 UIActionSheet *sheet;
                 //判断是否支持相机
                 if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                     
                     sheet = [[UIActionSheet alloc]initWithTitle:@"选取头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
                     
                 }else{
                     
                     sheet = [[UIActionSheet alloc]initWithTitle:@"选取头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
                     
                 }
                 sheet.tag = 301;
                 [sheet showInView:self.view];
                 
             }
             else
             {
                 //点击不允许时调用
                 return ;
             }
         }];
        
    }else{
        // denied 拒绝 // restricted 受限制
        NSString *title = @"应用想访问您的相机,请予以授权!";
        NSString *tips = @"设置方式:手机设置->隐私->相机";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:tips delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

#pragma mark ---- actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 301) {
        NSUInteger sourceType = 0;
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    //取消
                    return;
                    break;
                default:
                    break;
            }
        } else {
            if (buttonIndex == 2) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        imgPicker.sourceType = sourceType;
        [self presentViewController:imgPicker animated:YES completion:^{}];
    }
}

#pragma mark - UIImagePickerControllerDelegate 方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //压缩显示
    UIImageView *camImageView =[[UIImageView alloc] init];
    int w=image.size.width;
    int h=image.size.height;
    CGSize itemSize;
    CGRect imageRect;
    itemSize = CGSizeMake(50,50);
    imageRect = CGRectMake(0, 0,  50,50);
    UIGraphicsBeginImageContext(itemSize);
    [image drawInRect:imageRect];
    camImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //保存图片至本地，方法见下文
    imageForSend = image;
    imageViewForChangeHead.image = image;
}



- (IBAction)actionForSave:(id)sender {
//    NSString * strForSign = [NSString stringWithString:[Mycrypt encryptWithText:@"测试修改个性签名"]];
    NSString * strForSign =@"";
    [MBProgressHUD showMessage:@"正在提交..." toView:self.view];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 701;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_UserUpdate\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str4 = [NSString stringWithFormat:@"\"Sex\":\"%@\",", textFieldForSex.text];
    NSString *str5 = [NSString stringWithFormat:@"\"PhoneNumber\":\"%@\",", textFieldForPhone.text];
    NSString *str7 = [NSString stringWithFormat:@"\"Signature\":\"%@\",", strForSign];
    NSString *str8;
    if (!imageForSend) {
        str8 = [NSString stringWithFormat:@"\"ImageUrl\":\"\"}"];
    }else{
        str8 = [NSString stringWithFormat:@"\"ImageUrl\":\"%@\"}", [UIImageJPEGRepresentation(imageForSend, 0.4) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    }

    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str7 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str8 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getUserInfo
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
    request.tag = 700;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_UserInfo\","];
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
    if(_request.tag == 700)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            NSLog(@"Login succeed!!!");
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            NSDictionary * dicForUserInfo = [result objectForKey:@"Message"];
            
            [d setObject:[dicForUserInfo objectForKey:@"Code"] forKey:@"Code"];
            [d setObject:[dicForUserInfo objectForKey:@"CompanyName"] forKey:@"CompanyName"];
            NSLog(@"%@---------%@", [dicForUserInfo objectForKey:@"Signature"], [Mycrypt decryptWithText:[dicForUserInfo objectForKey:@"Signature"]]);
            [d setObject:[Mycrypt decryptWithText:[dicForUserInfo objectForKey:@"Signature"]] forKey:@"Signature"];
//            [d setObject:[MyDesCrypt textFromBase64String:[dicForUserInfo objectForKey:@"Signature"]] forKey:@"Signature"];
            [d setObject:[dicForUserInfo objectForKey:@"FullName"] forKey:@"FullName"];
            [d setObject:[dicForUserInfo objectForKey:@"Sex"] forKey:@"Sex"];
            [d setObject:[dicForUserInfo objectForKey:@"PhoneNumber"] forKey:@"PhoneNumber"];
            [d setObject:[dicForUserInfo objectForKey:@"ImageUrl"] forKey:@"ImageUrl"];
            [d setObject:[dicForUserInfo objectForKey:@"Email"] forKey:@"Email"];
            [d setObject:[dicForUserInfo objectForKey:@"DepartmentName"] forKey:@"DepartmentName"];
            [self reFresh];
            if (changeOK) {
                [MBProgressHUD hideHUDForView:self.view];
                [MBProgressHUD showSuccess:@"修改个人信息成功！"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MBProgressHUD hideHUDForView:self.view];
            }
        }
        else {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
    else if(_request.tag == 701)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            changeOK = YES;
            [self getUserInfo];
        }
        else{
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:[result objectForKey:@"Message"]];
        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:[result objectForKey:@"Message"]];
}

@end
