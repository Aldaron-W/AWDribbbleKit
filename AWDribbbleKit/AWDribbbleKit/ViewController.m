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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MVDribbbleKit* manager = [MVDribbbleKit sharedManager];
    [manager setClientID:@"62e59e5b76d04fd1c717da1f0259e911cbe2b6ba082042223dd25c3128b15577" clientSecret:@"a8f0fe3ac018e3db3090dd318377fcdbc45058af67b4f1fe1b29c3fd57d497be" callbackURL:@"http://www.aldaron.com.cn"];
    MVAuthBrowser * browser = [manager authorizeWithCompletion:^(NSError *error, BOOL stored) {
        ;
    }];
    
    if (![manager isAuthorized]) {
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
