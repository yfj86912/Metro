//
//  MyDesCrypt.h
//  shanghaiditie
//
//  Created by 21k on 15/6/19.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface MyDesCrypt : NSObject

+(NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key;
+(NSString*) decryptUseDES2:(NSString*)cipherText key:(NSString*)key;

@end
