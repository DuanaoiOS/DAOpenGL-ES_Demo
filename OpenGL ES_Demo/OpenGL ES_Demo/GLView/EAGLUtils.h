//
//  EAGLUtils.h
//  OpenGL ES_Demo
//
//  Created by DuanaoiOS on 2017/10/25.
//  Copyright © 2017年 DATree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface EAGLUtils : NSObject

+ (GLuint)compileShaderString:(NSString *)shaderString
                     withType:(GLenum)type;
+ (GLuint)compileShaderPath:(NSString *)path
                   withType:(GLenum)type;

+ (GLuint)setupTexture:(NSString *)fileName;
+ (GLuint)setupTextureImage:(UIImage *)image;

@end
