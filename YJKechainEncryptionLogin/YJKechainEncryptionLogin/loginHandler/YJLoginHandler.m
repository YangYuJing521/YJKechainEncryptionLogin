//
//  YJLoginHandler.m
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/11/24.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import "YJLoginHandler.h"
#import "NSString+Hash.h"
#import "SAMKeychain.h"

@interface YJLoginHandler()
@property (nonatomic, copy) void(^resultBlock)(BOOL result);
@property (nonatomic, copy) NSString *key; //秘钥
@property (nonatomic, copy) NSString *pwd; //密码明文
@property (nonatomic, copy) NSString *userName; //用户名
@end

@implementation YJLoginHandler
//钥匙串server
static NSString *const PASSWORDSERVER = @"PASSWORDSERVER";
static NSString *const KEYSERVER = @"KEYSERVER";
//盐
static NSString * const saltString = @"abcdefghijklmnopqrstuvwxyj1234567890!@#$%^&*()";

static YJLoginHandler *_instance = nil;
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YJLoginHandler alloc] init];
    });
    return _instance;
}

#pragma mark 登录
/** 自动登录 */
-(void)autoLoginIn:(void (^)(BOOL))resultBlock{
    self.resultBlock = resultBlock;
    if (self.isAutoLogin) {
        NSString *userName = [self getUserName];
        NSString *pwd = [self getPassWord];
        if (userName.length && pwd.length) {
            //获取秘钥
            NSString *key = [SAMKeychain passwordForService:KEYSERVER account:userName];
            if (key == nil) {
                //秘钥为空从服务器获取(简单演示)
                key = [self getKeyFromAccount:userName];
            }
            self.key = key;
            //将获取的秘钥保存到钥匙串
            [self saveKeyToKeychain];

            self.pwd = pwd;//密码明文
            self.userName = userName; //用户名
            NSString *encryptPWD = encrypMethodTwo(pwd,key); //加密
            //请求登录接口
            [self requestLoginWithUserName:userName encrypdPassword:encryptPWD];
        }
    }
}

/** 手动登录 */
-(void)logInWithUserName:(NSString *)userName password:(NSString *)password result:(void (^)(BOOL))resultBlock{
    self.resultBlock = resultBlock;
    NSString *key = [SAMKeychain passwordForService:KEYSERVER account:userName];
    if (key == nil) {
        //秘钥为空从服务器获取(简单演示)
        key = [self getKeyFromAccount:userName];
    }
    self.key = key;
    //将获取的秘钥保存到钥匙串
    [self saveKeyToKeychain];
    self.pwd = password;//密码明文
    self.userName = userName; //用户名
    NSString *encryptPWD = encrypMethodTwo(password,key); //加密
    //请求登录接口
    [self requestLoginWithUserName:userName encrypdPassword:encryptPWD];
}

#pragma mark 私有方法
-(NSString *)getUserName{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:userNameDefaults];
    return userName;
}

-(NSString *)getPassWord{
    NSString *account = [self getUserName];
    if (account.length<=0) {
        return @"";
    }
#pragma mark 从keychain中获取密码明文
    NSString *password = [SAMKeychain passwordForService:PASSWORDSERVER account:account];
    return password;
}

/** 是否记住密码 */
-(BOOL)isRmbPwd{
    BOOL isRember = [[NSUserDefaults standardUserDefaults] boolForKey:rmbPwdDefaults];
    return isRember;
}

/** 是否自动登录 */
-(BOOL)isAutoLogin{
    BOOL isAutoLog = [[NSUserDefaults standardUserDefaults] boolForKey:autoLoginDefaults];
    return isAutoLog;
}

#pragma mark 保存到钥匙串
//记住密码，自动登录数据
-(void)saveDataToKeychain{
    //用户名不涉及安全性可以用偏好保存
    [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:userNameDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //密码及秘钥操作要用钥匙串保存，在buildseeting中打开钥匙串权限才有效
    [SAMKeychain setPassword:self.pwd forService:PASSWORDSERVER account:self.userName];
}

//保存秘钥
-(void)saveKeyToKeychain{
    //不同的钥匙串操作对应的服务不用， 根据账号用户名获取
    [SAMKeychain setPassword:self.key forService:KEYSERVER account:self.userName];
}

#pragma mark 几种加密方式
/**
 * 第一种加密方式（加盐->md5->乱序->再md5）
 * 缺点：盐会直接暴露出来，一般不用
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

/** 第二种加密方式 HMAC
 *  思路：每个用户名对应一个秘钥
 *  秘钥保存在钥匙串中，如果没有从服务器获取
 */
NSString* encrypMethodTwo(NSString* password, NSString* key){
    password = [password hmacMD5StringWithKey:key];
    return password;
}

#pragma mark 模拟服务器请求
/** 根据账号获取秘钥 */
-(NSString *)getKeyFromAccount:(NSString *)account{
    //服务器返回秘钥思路；
    //第一种情况：需要授权（短信验证码等等），其它设备验证， 提示问题验证等等
    //第二种情况：不需要授权直接返回秘钥
    
    //简单演示没有授权
    if ([account isEqualToString:@"abc"]) {
        //和账户绑定的秘钥
        return @"test";
    }else{
        //@"没有登陆过，返回一个随机生成秘钥，登录成功后会在后台和账户绑定";
        return @"test";
    }
}

/** 请求登录 */
- (void)requestLoginWithUserName:(NSString *)name encrypdPassword:(NSString *)pwd{
    NSLog(@"%@",pwd);
    if ([name isEqualToString:@"abc"] && [pwd isEqualToString:@"f415befbadc361e6e7e945b85e20dbf2"]) {
        NSLog(@"登录成功");
        //自动登录或者记住密码状态下保存账号密码
        if ([self isAutoLogin]||[self isRmbPwd]) {
            [self saveDataToKeychain];
        }
        //返回登录结果
        if (self.resultBlock) {
            self.resultBlock(YES);
        }
    }else{
        NSLog(@"登录失败");
        //返回登录结果
        if (self.resultBlock) {
            self.resultBlock(NO);
        }

    }
}

@end
