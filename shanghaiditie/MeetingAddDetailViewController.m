//
//  MeetingAddDetailViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/5.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MeetingAddDetailViewController.h"
#import "AddDetailTableViewCell.h"
#import "Mycrypt.h"
#import "MyDesCrypt.h"

@interface MeetingAddDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MeetingAddDetailViewController
@synthesize dicForAddressInfo, labelForAddressName, labelForAddressNote;
@synthesize tableViewForMeeting;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tableViewForMeeting.delegate = self;
    tableViewForMeeting.dataSource = self;
    tableViewForMeeting.allowsSelection = NO;
    labelForAddressName.text = [dicForAddressInfo objectForKey:@"SiteName"];
    labelForAddressNote.text = [Mycrypt decryptWithText:[dicForAddressInfo objectForKey:@"SiteNote"]];
    
    arrFormeeting = [[NSMutableArray alloc]initWithArray:[dicForAddressInfo objectForKey:@"Children"]];
    
    if (arrFormeeting.count>0) {
        tableViewForMeeting.alpha = 1;
        [tableViewForMeeting reloadData];
    }else{
        tableViewForMeeting.alpha = 0;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrFormeeting.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [arrFormeeting objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"addDetailTableViewCell";
    AddDetailTableViewCell *cell = (AddDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell=[[AddDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.labelForMeetingName.text = [dic objectForKey:@"MeetingName"];
    cell.labelForMeetingStartTime.text = [dic objectForKey:@"UseBeginDate"];
    cell.labelForMeetingEndTime.text = [dic objectForKey:@"UseEndDate"];
    return cell;
    
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
