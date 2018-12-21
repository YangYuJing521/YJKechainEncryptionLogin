//
//  MainViewController.m
//  YJKechainEncryptionLogin
//
//  Created by yangyujing on 2018/12/18.
//  Copyright © 2018年 yangyujing. All rights reserved.
//

#import "MainViewController.h"
#import "YJLoginHandler.h"
#import "EncryptionTools.h"
#import "RSACryptor.h"

@interface MainViewController ()
@end

@implementation MainViewController
{
    NSString *keyString;  //加密key
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"加密演示页面";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"点击退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    self.navigationItem.rightBarButtonItem = rightitem;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 50)];
    tipsLabel.numberOfLines = 0;
    tipsLabel.text = @"点击屏幕演示加密及解密，touchesBegan中选择对应加密方式";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLabel];
    
    #pragma mark rsa 公钥私钥初始化设置
    //设置rsa秘钥尺寸，和生成证书时长度一致
    [[RSACryptor sharedRSACryptor] generateKeyPair:512];
    NSString *publicPath = [[NSBundle mainBundle] pathForResource:@"rsacert.der" ofType:nil];
    NSString *privatePath = [[NSBundle mainBundle] pathForResource:@"p.p12" ofType:nil];
    [[RSACryptor sharedRSACryptor] loadPublicKey:publicPath];
    //密码和生成p.p12时输入的一致，一般所以要用私钥解密就要传这个密码
    //公钥加密私钥解密，一般私钥都在服务器，这里只演示
    [[RSACryptor sharedRSACryptor] loadPrivateKey:privatePath password:@"123456"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    keyString = @"abc";

    //AES ECB
//    [self AES_ECB];
    
    //AES CBC
//    [self AES_CBC];
    
    //DES ECB
//    [self DES_ECB];
    
    //3DES CBC
//    [self DES_CBC];
    
    //RSA 非对称加密
    [self rsaEncrypt];
}

#pragma mark 对称加密
//AES 高级加密算法,  ECB
-(void)AES_ECB{
    [EncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmAES;
    NSString *eccryptString = [[EncryptionTools sharedEncryptionTools] encryptString:@"hello" keyString:keyString iv:nil];
    //加密完成是nsdata base64 方法返回的字符串是对nsdatad处理后的数据
    NSLog(@"AES_ECB加密：%@",eccryptString);
    
    NSString *decryptString = [[EncryptionTools sharedEncryptionTools] decryptString:eccryptString keyString:keyString iv:nil];
    NSLog(@"AES_ECB解密：%@",decryptString);
}

//CBC 加密方式（牵一发动全城，链式篡改一处会影响后面数据的加密），需要向量
-(void)AES_CBC{
    [EncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmAES;
    //向量
    uint8_t iv[8] = {1,2,3,4,5,6,7,8};  //只要8个数字，内容任意
    //将向量转为nsdata
    NSData *ivdata = [NSData dataWithBytes:iv length:sizeof(iv)];
    NSString *eccryptString = [[EncryptionTools sharedEncryptionTools] encryptString:@"hello" keyString:keyString iv:ivdata];
    //加密完成是nsdata base64 方法返回的字符串是对nsdatad处理后的数据
    NSLog(@"AES_CBC加密：%@",eccryptString);
    
    NSString *decryptString = [[EncryptionTools sharedEncryptionTools] decryptString:eccryptString keyString:keyString iv:ivdata];
    NSLog(@"AES_CBC解密：%@",decryptString);
}

//DES标准加密算法
-(void)DES_ECB{
    [EncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmDES;
    NSString *encryptString = [[EncryptionTools sharedEncryptionTools] encryptString:@"hello" keyString:keyString iv:nil];
    NSLog(@"DES_ECB加密%@",encryptString);
    
    NSString *decryptString = [[EncryptionTools sharedEncryptionTools] decryptString:encryptString keyString:keyString iv:nil];
    NSLog(@"DES_ECB解密%@",decryptString);
}

-(void)DES_CBC{
    [EncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmDES;
    uint8_t iv[8] = {1,2,3,4,5,6,7,8};
    NSData *ivData = [NSData dataWithBytes:iv length:sizeof(iv)];
    NSString *encryptString = [[EncryptionTools sharedEncryptionTools] encryptString:@"hello" keyString:keyString iv:ivData];
    NSLog(@"DES_CBC加密%@",encryptString);
    
    NSString *deCryptString = [[EncryptionTools sharedEncryptionTools] decryptString:encryptString keyString:keyString iv:ivData];
    NSLog(@"DES_CBC解密%@",deCryptString);
}

#pragma mark 非对称加密
-(void)rsaEncrypt{
    NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
    //加密后的data都是base64编码
    NSData *encryptData = [[RSACryptor sharedRSACryptor] encryptData:data];
    NSLog(@"rsa 加密:%@",[encryptData base64EncodedStringWithOptions:0]);
    NSData *decryptData = [[RSACryptor sharedRSACryptor] decryptData:encryptData];
    NSString *decryptString = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    NSLog(@"rsa 解密：%@",decryptString);
}

#pragma mark 退出登录
-(void)logOut{
    [[YJLoginHandler sharedInstance] logOut];
}
@end
