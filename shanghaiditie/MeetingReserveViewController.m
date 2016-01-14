//
//  MeetingReserveViewController.m
//  shanghaiditie
//
//  Created by 21k on 15/6/9.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MeetingReserveViewController.h"
#import "MeetingReserveStepTwoViewController.h"
#import "RBCustomDatePickerView.h"

@interface MeetingReserveViewController ()<UITextFieldDelegate, RBCustomDatePickerViewDelegate>
{
//    UIDatePicker * datePicker;
//    UIView * dateView;
    RBCustomDatePickerView *pickerView;
    
    NSString * timeStr;
    BOOL witchTime;
}

@end

@implementation MeetingReserveViewController
@synthesize meetinfhold, meetingEnd, meetingName, meetingStart;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    meetingStart.delegate = self;
    meetinfhold.delegate = self;
    meetingName.delegate = self;
    meetingEnd.delegate = self;
    
//    [self chooseTime];
//    dateView.alpha =0;
    
    pickerView = [[RBCustomDatePickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
    pickerView.alpha = 0;
    
    UIDatePicker * datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- RBCustomDatePickerViewDelegate
-(void)chooseTimeStr:(NSString *)strForTime
{
    if (witchTime) {
        meetingStart.text = strForTime;
    }else{
        meetingEnd.text = strForTime;
    }

}

#pragma mark -- UItextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == meetingStart || textField == meetingEnd) {
        [meetingName resignFirstResponder];
        [meetinfhold resignFirstResponder];
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == meetingStart || textField == meetingEnd) {
        [meetingName resignFirstResponder];
        [meetinfhold resignFirstResponder];
        [textField resignFirstResponder];
//        dateView.alpha = 1;
        pickerView.alpha = 1;
        if (textField == meetingStart) {
            witchTime = YES;
        }else{
            witchTime = NO;
        }
    }else
    {
        self.view.frame = CGRectMake(0, -40, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)comeback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextAction:(id)sender {
    if ([meetingName.text isEqual:@""]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入会议名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([meetinfhold.text isEqual:@""]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入会议主持人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([meetingStart.text isEqual:@""]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入会议开始时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([meetingEnd.text isEqual:@""]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入会议结束时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MeetingReserveStepTwoViewController * meetingReserveStepTwoViewController = [storyboard instantiateViewControllerWithIdentifier:@"meetingReserveStepTwoViewController"];
    meetingReserveStepTwoViewController.strForBeginDate = [[NSString alloc]initWithFormat:@"%@", meetingStart.text];
    meetingReserveStepTwoViewController.strForEndDate = [[NSString alloc]initWithFormat:@"%@", meetingEnd.text];
    meetingReserveStepTwoViewController.strForMeetingName = [[NSString alloc]initWithFormat:@"%@", meetingName.text];
    meetingReserveStepTwoViewController.strForMeetingHost = [[NSString alloc]initWithFormat:@"%@", meetinfhold.text];
    [self.navigationController pushViewController:meetingReserveStepTwoViewController animated:YES];
}

@end
