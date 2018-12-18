//
//  MainViewController.m
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/12/18.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import "MainViewController.h"
#import "YJLoginHandler.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"点击退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    self.navigationItem.rightBarButtonItem = rightitem;
}

-(void)logOut{
    [[YJLoginHandler sharedInstance] logOut];
}
@end
