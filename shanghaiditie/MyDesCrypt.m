//
//  MyDesCrypt.m
//  shanghaiditie
//
//  Created by 21k on 15/6/19.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MyDesCrypt.h"
#import "GTMBase64.h"
#import "MyData.h"
//#define __BASE64( text )        [CommonFunc base64StringFromText:text]
//#define __TEXT( base64 )        [CommonFunc textFromBase64String:base64]
////空字符串
//#define     LocalStr_None           @""
//static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation MyDesCrypt

+ (NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key
{
    NSData* bytes = [key dataUsingEncoding:NSUTF8StringEncoding];
    // 注意这里应该跟java,.net一致,我们使用的iv就是key.getBytes;
    Byte * myByte = (Byte *)[bytes bytes];
    
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          nil,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        ciphertext = [GTMBase64 stringByEncodingData:data];
    }
    return ciphertext;
}

+(NSString*) decryptUseDES2:(NSString*)cipherText key:(NSString*)key {
    
    NSData* bytes = [key dataUsingEncoding:NSUTF8StringEncoding];
    // 注意这里应该跟java,.net一致,我们使用的iv就是key.getBytes;
    Byte * myByte = (Byte *)[bytes bytes];
    // 注意这里是用base64解的码,也就是说.net服务端必须是base64.encode
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          1024,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}


@end
