//
//  SecondLevelViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/4/15.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "SecondLevelViewController.h"
#import "SalaryInfoViewController.h"
#import "ServiceNewsViewController.h"
#import "MyMeetingViewController.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "MyYudingMeetingViewController.h"
#import "MeetingAddressViewController.h"
#import "ShowMessageNumberButton.h"
#import "MeetingReserveViewController.h"
#import "FileListViewController.h"
#import "VideoWebViewController.h"
#import "FileSeachViewController.h"

#define tophight 64

@interface SecondLevelViewController ()<ServiceNewsViewControllerDelegate>

@end

@implementation SecondLevelViewController
@synthesize typeNumber;
@synthesize DicForFoundtion;
@synthesize labelForTitle;
@synthesize FirstdepartmentId;
@synthesize arrayForChildrenMessageCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrayForIcons = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(poptoHere) name:@"poptoHere" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    labelForTitle.text = [DicForFoundtion objectForKey:@"TypeName"];
}

-(void)getIcons
{
    arrayForChildFoundtion = [DicForFoundtion objectForKey:@"Children"];
    for (int i =0; i<arrayForChildFoundtion.count; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int number = i;
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[arrayForChildFoundtion objectAtIndex:number] objectForKey:@"TypeImgUrl"]]];
            NSDictionary * dic = [[NSDictionary alloc]initWithObjectsAndKeys:imageData, @"imagedata",[[arrayForChildFoundtion objectAtIndex:number] objectForKey:@"Type"], @"type", nil];
            [arrayForIcons addObject:dic];
            
            if (arrayForIcons.count==arrayForChildFoundtion.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addButtons];
                });
            }
        });
    }
}


-(void)addButtons;
{
    arrayForChildFoundtion = [DicForFoundtion objectForKey:@"Children"];
    for (int i=0; i<arrayForChildFoundtion.count; i++) {
        NSDictionary * dic;
        for (dic in arrayForIcons) {
            if ([[dic objectForKey:@"type"] isEqual:[[arrayForChildFoundtion objectAtIndex:i] objectForKey:@"Type"]]) {
                break;
            }
        }
        UIImage * imageForIcon = [UIImage imageWithData:[dic objectForKey:@"imagedata"]];
        NSLog(@"%f------%f", imageForIcon.size.width, imageForIcon.size.height);
        
        int x, y, interval;
        interval = ([UIScreen mainScreen].bounds.size.width-imageForIcon.size.width/2*4)/5;
        x = interval*(1+i%4) + i%4*imageForIcon.size.width/2;
        y = 35*(i/4 + 1) + tophight + imageForIcon.size.height/2*(i/4);
        
        NSLog(@"%d------%d", x, y);
        ShowMessageNumberButton * btn = [ShowMessageNumberButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, imageForIcon.size.width/2, imageForIcon.size.height/2);
        [btn setBackgroundImage:imageForIcon forState:UIControlStateNormal];
        btn.tag = [[[arrayForChildFoundtion objectAtIndex:i] objectForKey:@"Type"] intValue];
        [btn addTarget:self action:@selector(btnActionChoose:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn addMessageNumber];
        btn.imageViewForMessageBackground.alpha = 0;
        btn.labelForNumber.alpha = 0;
        
        UILabel * labelForBtn =[[UILabel alloc]initWithFrame:CGRectMake(x-15, y+imageForIcon.size.height/2+5, imageForIcon.size.width/2+30, 21)];
        labelForBtn.font = [UIFont systemFontOfSize:12];
        labelForBtn.textAlignment = NSTextAlignmentCenter;
        labelForBtn.text = [[arrayForChildFoundtion objectAtIndex:i] objectForKey:@"TypeName"];
        labelForBtn.textColor = [UIColor blackColor];
        [self.view addSubview:labelForBtn];
    }
    
    [self showNewsNumber];
}

///首页图标显示未读消息数量接口
-(void)showNewsNumber
{
    for (int i = 0; i<arrayForChildrenMessageCount.count; i++) {
        NSDictionary *dic = [arrayForChildrenMessageCount objectAtIndex:i];
        if([[dic objectForKey:@"Count"] intValue]==0)
            continue;
        
        for (ShowMessageNumberButton * btn in self.view.subviews) {
            if (btn.tag == [[dic objectForKey:@"Type"] intValue]) {
                btn.imageViewForMessageBackground.alpha = 1;
                btn.labelForNumber.alpha = 1;
                btn.labelForNumber.text = [dic objectForKey:@"Count"];
                break;
            }
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//////根据tag 选择进行操作
-(IBAction)btnActionChoose:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    switch (btn.tag) {
        case 24:
        case 25:
        case 26:
        case 27:
        case 28:
        case 29:
        case 30:
        case 20:
        case 31:
        case 32:
        case 33:
        case 34:
        case 35:
        case 36:
        case 37:
            [self actionForNews:(int)btn.tag];
            break;
        case 38:
            [self actionForMyyuding:(int)btn.tag];
            break;
        case 39:
            [self actionForMeetingAddress:(int)btn.tag];
            break;
        case 17:
            [self actionForwenjian:(int)btn.tag];
            break;
        case 18:
            [self actionForyuding:(int)btn.tag];
            break;
        case 19:
            [self actionForMyMeeting:(int)btn.tag];
            break;
        case 16:
            [self actionForSalary:(int)btn.tag];
            break;
        case 40:
        case 41:
        case 42:
            [self actionForVideo:(int)btn.tag];
            break;
        case 43:
        case 44:
        case 45:
        case 46:
            [self actionForFile:(int)btn.tag];
            break;
        default:
            break;
    }
}


- (void)actionForwenjian:(int)tagNumber {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    FileListViewController * fileListViewController = [storyboard instantiateViewControllerWithIdentifier:@"fileListViewController"];
    [self.navigationController pushViewController:fileListViewController animated:YES];
}

- (void)actionForyuding:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MeetingReserveViewController * meetingReserveViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingReserveViewController"];
    [self.navigationController pushViewController:meetingReserveViewController animated:YES];
}

- (void)actionForMyMeeting:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MyMeetingViewController * myMeetingViewController = [storyboard instantiateViewControllerWithIdentifier:@"myMeetingViewController"];
    [self.navigationController pushViewController:myMeetingViewController animated:YES];
}

- (void)actionForMyyuding:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MyYudingMeetingViewController * myYudingMeetingViewController = [storyboard instantiateViewControllerWithIdentifier:@"myYudingMeetingViewController"];
    [self.navigationController pushViewController:myYudingMeetingViewController animated:YES];
}

- (void)actionForMeetingAddress:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MeetingAddressViewController * meetingAddressViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingAddressViewController"];
    [self.navigationController pushViewController:meetingAddressViewController animated:YES];
}


- (void)actionForNews:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ServiceNewsViewController * serviceNewsViewController = [storyboard instantiateViewControllerWithIdentifier:@"serviceNewsViewController"];
    serviceNewsViewController.FirstdepartmentId = FirstdepartmentId;
    serviceNewsViewController.strFortitle = [NSString stringWithFormat:@"%@新闻",labelForTitle.text];
    serviceNewsViewController.delegate = self;
    serviceNewsViewController.tagNumber = tagNumber;
    [self.navigationController pushViewController:serviceNewsViewController animated:YES];

}

- (void)actionForSalary:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SalaryInfoViewController * salaryInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"salaryInfoViewController"];
    salaryInfoViewController.chooseYear = -1;
    [self.navigationController pushViewController:salaryInfoViewController animated:YES];

}

- (void)actionForVideo:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    VideoWebViewController * videoWebViewController = [storyboard instantiateViewControllerWithIdentifier:@"videoWebViewController"];
    videoWebViewController.witchWebview = tagNumber;
    [self.navigationController pushViewController:videoWebViewController animated:YES];
    
}

- (void)actionForFile:(int)tagNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    FileSeachViewController * fileSeachViewController = [storyboard instantiateViewControllerWithIdentifier:@"fileSeachViewController"];
    fileSeachViewController.witchFile = tagNumber;
    [self.navigationController pushViewController:fileSeachViewController animated:YES];
    
}

#pragma --mark ServiceNewsViewControllerdelegate
-(void)showReadNumber:(int)Number tag:(int)tagNum
{
    for (ShowMessageNumberButton * btn in self.view.subviews) {
        if (btn.tag == tagNum) {
            if([btn.labelForNumber.text intValue]-Number<=0)
            {
                return;
            }
            btn.imageViewForMessageBackground.alpha = 1;
            btn.labelForNumber.alpha = 1;
            btn.labelForNumber.text = [NSString stringWithFormat:@"%d", [btn.labelForNumber.text intValue]-Number];
            break;
        }
    }
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)poptoHere
{
    [self.navigationController popToViewController:self animated:YES];
}

@end
