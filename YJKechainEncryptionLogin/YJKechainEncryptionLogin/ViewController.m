//
//  ViewController.m
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/6/1.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Hash.h"
#import "SAMKeychain.h"

//盐
static NSString * const saltString = @"abcdefghijklmnopqrstuvwxyj1234567890!@#$%^&*()";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/**
 * 登录按钮点击事件
 */
- (IBAction)loginBtnClick:(UIButton *)sender {
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    NSString *hashdPwd = encrypMethodOne(password);
    if (userName && password) {
        [self requestLoginWithUserName:userName password:hashdPwd];
    }
    
}


/**
 * 第一种加密方式（加盐->md5->乱序->再md5）
 * 缺点：盐会直接暴露出来
 */
NSString* encrypMethodOne(NSString* password){
    //1. 加盐
    password = [password stringByAppendingString:saltString];
    //2. md5加密
    password = password.md5String;
    //3. 乱序
    NSString *tmpStr1 = [password substringToIndex:12];
    NSString *tmpStr2 = [password substringFromIndex:12];
    NSString *finalStr = [NSString stringWithFormat:@"%@%@",tmpStr2,tmpStr1];
    //乱序后的再进行md5加密并返回
    return finalStr.md5String;
}

/**
 * 第二种加密方式 HMAC
 */
NSString* encrypMethodTwo(NSString* password){
 
    NSString *key = nil;
    password = [password hmacMD5StringWithKey:key];

    return password;
}

/**
 * 简单模仿服务器请求
 */
- (void)requestLoginWithUserName:(NSString *)name password:(NSString *)pwd{
    NSLog(@"%@",pwd);
    if ([name isEqualToString:@"abc"] && [pwd isEqualToString:@"601efeaacfcd59e063a0a56567a67980"]) {
        NSLog(@"登录成功");
    }else{
        NSLog(@"登录失败");
    }
}

@end
