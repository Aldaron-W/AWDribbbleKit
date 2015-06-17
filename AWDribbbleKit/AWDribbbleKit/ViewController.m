//
//  ViewController.m
//  AWDribbbleKit
//
//  Created by mafengwo on 15/6/17.
//  Copyright (c) 2015年 Aldaron. All rights reserved.
//

#import "ViewController.h"
#import "MVDribbbleKit.h"

@interface ViewController ()

#pragma mark - Status
@property (weak, nonatomic) IBOutlet UILabel *StatusLab;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[MVDribbbleKit sharedManager] setClientID:@"62e59e5b76d04fd1c717da1f0259e911cbe2b6ba082042223dd25c3128b15577" clientSecret:@"a8f0fe3ac018e3db3090dd318377fcdbc45058af67b4f1fe1b29c3fd57d497be" callbackURL:@"http://www.aldaron.com.cn"];
}

- (void)viewDidAppear:(BOOL)animated{
    if ([[MVDribbbleKit sharedManager] isAuthorized]) {
        self.StatusLab.text = @"已登录";
        [self.loginBtn setHidden:YES];
    }
    else{
        self.StatusLab.text = @"未登录";
        [self.loginBtn setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TouchEvents
- (IBAction)loginBtnTouchEvent:(id)sender forEvent:(UIEvent *)event {
    MVAuthBrowser * browser = [[MVDribbbleKit sharedManager] authorizeWithCompletion:^(NSError *error, BOOL stored) {
        ;
    }];
    [self.navigationController pushViewController:browser animated:YES];
}

- (IBAction)getCurrentUserInfoBtnTouchEvent:(id)sender forEvent:(UIEvent *)event {
    
    [[MVDribbbleKit sharedManager] getDetailsForUser:nil success:^(MVUser *user, NSHTTPURLResponse *response) {
        ;
    } failure:^(NSError *error, NSHTTPURLResponse *response) {
        ;
    }];
}

@end
