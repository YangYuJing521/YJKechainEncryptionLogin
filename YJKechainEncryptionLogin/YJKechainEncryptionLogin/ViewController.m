//
//  ViewController.m
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/6/1.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import "ViewController.h"
#import "MDProgressHUD.h"
#import "YJLoginHandler.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberPwdSwitch;  //记住密码开关
@property (weak, nonatomic) IBOutlet UISwitch *autoLoginSwitch;    //自动登录开关

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning 登录成功测试账号：abc  密码：123
    //初始化
    YJLoginHandler *loginHandler = [YJLoginHandler sharedInstance];
    [self.rememberPwdSwitch setOn:[loginHandler isRmbPwd]];
    [self.autoLoginSwitch setOn:[loginHandler isAutoLogin]];
    self.userNameField.text = [loginHandler getUserName];
    self.passwordField.text = [loginHandler getPassWord];
    self.autoLoginSwitch.enabled = self.rememberPwdSwitch.isOn;
    //自动登录方法
    [loginHandler autoLoginIn:^(BOOL isSuccess) {
        if (isSuccess) { //自动登录成功
            [self longInSucceedJump];
        }else{
            [self ShowText:@"自动登录失败"];
        }
    }];
}


#pragma mark 点击事件
/** 登录按钮点击事件 */
- (IBAction)loginBtnClick:(UIButton *)sender {
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    [[YJLoginHandler sharedInstance] logInWithUserName:userName password:password result:^(BOOL isSuccess) {
        if (isSuccess) { //登录成功
            [self longInSucceedJump];
        }else{
            [self ShowText:@"手动登录失败"];
        }

    }];
}

/** 记住密码switch点击时间 */
- (IBAction)remenberPasswordClick:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:rmbPwdDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //记住密码影响自动登录的相关状态
    if (!sender.isOn) { //不记住密码也就关闭了自动登录
        [self.autoLoginSwitch setOn:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:autoLoginDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.autoLoginSwitch.enabled = sender.isOn;
}

/** 自动登录switch点击事件 */
- (IBAction)autoLoginClick:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:autoLoginDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 私有方法
/** 登陆成功后跳转 */
-(void)longInSucceedJump{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.title = @"成功后跳转";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}
/** 提示 */
-(void)ShowText:(NSString *)text{
    MDProgressHUD *hud = [MDProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MDProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:2.0f];
}


@end
