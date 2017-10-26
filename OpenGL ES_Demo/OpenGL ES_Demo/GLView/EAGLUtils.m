//
//  EAGLUtils.m
//  OpenGL ES_Demo
//
//  Created by DuanaoiOS on 2017/10/25.
//  Copyright © 2017年 DATree. All rights reserved.
//

#import "EAGLUtils.h"


@implementation EAGLUtils

#pragma mark - Shader
+ (GLuint)compileShaderString:(NSString *)shaderString withType:(GLenum)type {
    //创建一个代表shader的OpenGL对象
    GLuint shader = glCreateShader(type);
    const char *shaderUTF8string = shaderString.UTF8String;
    //获取shader的源代码
    glShaderSource(shader, 1, &shaderUTF8string, NULL);
    //编译shader
    glCompileShader(shader);
    GLint compiledSuccess;
    //查询shader编译状态信息 是否编译成功
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiledSuccess);
    if (compiledSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Failed to compile shader %@", messageString);
        return 0;
    }
    
    return shader;
}

+ (GLuint)compileShaderPath:(NSString *)path withType:(GLenum)type {
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (error) {
        NSLog(@"Error with loading shader %@", error);
        return 0;
    }
    return [self compileShaderString:shaderString
                            withType:type];
}


#pragma mark - Texture
+ (GLuint)setupTexture:(NSString *)fileName {

    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }

    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);

    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));

    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);

    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);

    CGContextRelease(spriteContext);

    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLuint)width, (GLuint)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);

    free(spriteData);

    return texName;
}

+ (GLuint)setupTextureImage:(UIImage *)image {

    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    GLubyte *imageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);

    glEnable(GL_TEXTURE_2D);

    GLuint texture2D;
    glGenTextures(1, &texture2D);
    glBindTexture(GL_TEXTURE_2D, texture2D);


    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLuint)width, (GLuint)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    glBindTexture(GL_TEXTURE_2D, 0);
    CGContextRelease(context);
    free(imageData);

    return texture2D;
}

















@end
