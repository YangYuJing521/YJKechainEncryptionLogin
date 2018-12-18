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
#import <LocalAuthentication/LocalAuthentication.h>
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

- (IBAction)zhiWenAuth:(UIButton *)sender {
    if ([UIDevice currentDevice].systemVersion.floatValue>=8.0) {//ios8.0以后支持
        LAContext *contex = [[LAContext alloc] init];
        //LAPolicyDeviceOwnerAuthentication  //2次失败后弹出密码验证
        //LAPolicyDeviceOwnerAuthenticationWithBiometrics  3次+2次没通过 不会再验证
        if ([contex canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {//iphone 5s以后支持
            
            //执行验证
            [contex evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"开启指纹验证以开启高级功能" reply:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self ShowText:@"验证成功"];
                    });
                }else{
                    
                    /*
                     LAErrorAuthenticationFailed - 指纹无法识别
                     LAErrorUserCancel     --用户点击了取消
                     LAErrorUserFallback   --用户点击了输入密码
                     LAErrorSystemCancel   --系统取消
                     LAErrorPasscodeNotSet --因为你设备上没有设置密码
                     LAErrorTouchIDNotAvailable  --设备没有Touch ID
                     LAErrorTouchIDNotEnrolled   --因为你的用户没有输入指纹
                     LAErrorTouchIDLockout --多次输入，密码锁定
                     LAErrorAppCancel--    比如电话进入，用户不可控的
                     */
                    
                    switch (error.code) {
                        case LAErrorAuthenticationFailed:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self ShowText:@"指纹无法识别"];
                            });
                            
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
            }];
            
        }else{
            [self ShowText:@"不支持指纹识别"];
        }
    }
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
