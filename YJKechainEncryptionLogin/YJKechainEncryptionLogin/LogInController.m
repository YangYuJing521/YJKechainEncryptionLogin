//
//  ViewController.m
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/6/1.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import "LogInController.h"
#import "MDProgressHUD.h"
#import "YJLoginHandler.h"
@interface LogInController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberPwdSwitch;  //记住密码开关
@property (weak, nonatomic) IBOutlet UISwitch *autoLoginSwitch;    //自动登录开关

@end

@implementation LogInController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning 登录成功测试账号：abc  密码：123
    //初始化
    YJLoginHandler *loginHandler = [YJLoginHandler sharedInstance];
    [self.rememberPwdSwitch setOn:[loginHandler isRmbPwd]];
    [self.autoLoginSwitch setOn:[loginHandler isAutoLogin]];
    if ([loginHandler isRmbPwd] || [loginHandler isAutoLogin]) {
        self.userNameField.text = [loginHandler getUserName];
        self.passwordField.text = [loginHandler getPassWord];
    }
    self.passwordField.secureTextEntry = YES;
    self.autoLoginSwitch.enabled = self.rememberPwdSwitch.isOn;
    
}

#pragma mark 点击事件
/** 登录按钮点击事件 */
- (IBAction)loginBtnClick:(UIButton *)sender {
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    [[YJLoginHandler sharedInstance] logInWithUserName:userName password:password result:^(BOOL isSuccess) {
        if (isSuccess) { //登录成功
            [[NSNotificationCenter defaultCenter] postNotificationName:LogInSucceedNotificaton object:nil];
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

/** 指纹验证 */
- (IBAction)zhiWenAuth:(UIButton *)sender {
    [[YJLoginHandler sharedInstance] LocalAuthenticationWithReason:@"开启指纹以验证高级功能" Succeed:^(BOOL success, NSString *errMsg) {
        if (success) {
            [self ShowText:@"指纹验证成功"];
        }else{
            [self ShowText:errMsg];
        }

    }];
}

#pragma mark 私有方法
/** 提示 */
-(void)ShowText:(NSString *)text{
    MDProgressHUD *hud = [MDProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MDProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:2.0f];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
