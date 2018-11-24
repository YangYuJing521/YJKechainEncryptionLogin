//
//  YJLoginHandler.h
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/11/24.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import <Foundation/Foundation.h>
#define rmbPwdDefaults @"rmbPwdDefaults"
#define autoLoginDefaults @"autoLoginDefaults"
#define userNameDefaults @"userNameDefaults"

@interface YJLoginHandler : NSObject
+(instancetype)sharedInstance;

#pragma mark 登录方法
/** 自动登录 */
-(void)autoLoginIn:(void(^)(BOOL))resultBlock;
/**
 * 手动登录
 * @ param userName 用户名
 * @ param password 密码明文
 * @ param resultBlock 登录结果
 */
-(void)logInWithUserName:(NSString *)userName
                password:(NSString *)password
                  result:(void(^)(BOOL))resultBlock;

#pragma mark 初始化
/** 获取用户名 */
-(NSString *)getUserName;
/** 获取密码明文（非加密展示用） */
-(NSString *)getPassWord;
/** 是否记住密码 */
-(BOOL)isRmbPwd;
/** 是否自动登录 */
-(BOOL)isAutoLogin;

@end


