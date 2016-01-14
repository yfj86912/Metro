//
//  MyData.m
//  shanghaiditie
//
//  Created by 21k on 15/6/19.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "MyData.h"

@implementation NSData(MyData)

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)base64Encoding
{
    if (self.length == 0)
        return @"";
    char *characters = malloc(self.length*3/2);
    if (characters == NULL)
        return @"";
    int end = self.length - 3;
    int index = 0;
    int charCount = 0;
    int n = 0;
    
    while (index <= end) {
        int d = (((int)(((char *)[self bytes])[index]) & 0x0ff) << 16)
        | (((int)(((char *)[self bytes])[index + 1]) & 0x0ff) << 8)
        | ((int)(((char *)[self bytes])[index + 2]) & 0x0ff);
        
        characters[charCount++] = encodingTable[(d >> 18) & 63];
        characters[charCount++] = encodingTable[(d >> 12) & 63];
        characters[charCount++] = encodingTable[(d >> 6) & 63];
        characters[charCount++] = encodingTable[d & 63];
        
        index += 3;
        
        if(n++ >= 14)
        {
            n = 0;
            characters[charCount++] = ' ';
        }
    }
    if(index == self.length - 2)
    {
        int d = (((int)(((char *)[self bytes])[index]) & 0x0ff) << 16)
        | (((int)(((char *)[self bytes])[index + 1]) & 255) << 8);
        characters[charCount++] = encodingTable[(d >> 18) & 63];
        characters[charCount++] = encodingTable[(d >> 12) & 63];
        characters[charCount++] = encodingTable[(d >> 6) & 63];
        characters[charCount++] = '=';
    }
    else if(index == self.length - 1)
    {
        int d = ((int)(((char *)[self bytes])[index]) & 0x0ff) << 16;
        characters[charCount++] = encodingTable[(d >> 18) & 63];
        characters[charCount++] = encodingTable[(d >> 12) & 63];
        characters[charCount++] = '=';
        characters[charCount++] = '=';
    }
    NSString * rtnStr = [[NSString alloc] initWithBytesNoCopy:characters length:charCount encoding:NSUTF8StringEncoding freeWhenDone:YES];
    return rtnStr;
}

//public static byte[] decode(String s) {
//    ByteArrayOutputStream bos = new ByteArrayOutputStream();
//    try {
//        decode(s, bos);
//    } catch (IOException e) {
//        throw new RuntimeException();
//    }
//    byte[] decodedBytes = bos.toByteArray();
//    try {
//        bos.close();
//        bos = null;
//    } catch (IOException ex) {
//        System.err.println("Error while decoding BASE64: " + ex.toString());
//    }
//    return decodedBytes;
//}
//private static void decode(String s, OutputStream os) throws IOException {
//    int i = 0;
//    
//    int len = s.length();
//    
//    while (true) {
//        while (i < len && s.charAt(i) <= ' ')
//            i++;
//        
//        if (i == len)
//            break;
//        int tri = (decode(s.charAt(i)) << 18)
//        + (decode(s.charAt(i + 1)) << 12)
//        + (decode(s.charAt(i + 2)) << 6)
//        + (decode(s.charAt(i + 3)));
//        os.write((tri >> 16) & 255);
//        if (s.charAt(i + 2) == '=')
//            break;
//        os.write((tri >> 8) & 255);
//        if (s.charAt(i + 3) == '=')
//            break;
//        os.write(tri & 255);
//        
//        i += 4;
//    }
//}
//private static int decode(char c) {
//    if (c >= 'A' && c <= 'Z')
//        return ((int) c) - 65;
//    else if (c >= 'a' && c <= 'z')
//        return ((int) c) - 97 + 26;
//    else if (c >= '0' && c <= '9')
//        return ((int) c) - 48 + 26 + 26;
//    else
//        switch (c) {
//            case '+':
//                return 62;
//            case '/':
//                return 63;
//            case '=':
//                return 0;
//            default:
//                throw new RuntimeException("unexpected code: " + c);
//        }
//}

@end
