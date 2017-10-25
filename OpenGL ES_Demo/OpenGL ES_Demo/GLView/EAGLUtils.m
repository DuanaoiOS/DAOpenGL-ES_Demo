//
//  EAGLUtils.m
//  OpenGL ES_Demo
//
//  Created by DuanaoiOS on 2017/10/25.
//  Copyright © 2017年 DATree. All rights reserved.
//

#import "EAGLUtils.h"


@implementation EAGLUtils

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

@end
