//
//  DAGLView.m
//  OpenGL ES_Demo
//
//  Created by DuanaoiOS on 2017/10/25.
//  Copyright © 2017年 DATree. All rights reserved.
//

#import "DAGLView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "EAGLUtils.h"

#import "CC3GLMatrix.h"

typedef struct {
    float Position[3];
    float Color[4];
}Vertex;

//const Vertex Vertices[] = {
//    {{1, -1, -7}, {1, 0, 0, 1}},
//    {{1, 1, -7}, {0, 1, 0, 1}},
//    {{-1, 1, -7}, {0, 0, 1, 1}},
//    {{-1, -1, -7}, {0, 0, 0, 1}}
//};

//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}}
//};
//
//const GLubyte Indices[] = {
//    0, 1, 2,
//    2, 3, 0
//};
const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    {{1, -1, -1}, {1, 0, 0, 1}},
    {{1, 1, -1}, {1, 0, 0, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};

@interface DAGLView(){
    CAEAGLLayer *_eaglLayer;        // 视图层，必须在CAEAGLLayer上才能绘制OpenGLES内容
    EAGLContext *_eaglContext;      // OpenGLES的渲染上下文
    GLuint       _colorRenderBuffer;// 存储渲染的内容
    GLuint       _frameBuffer;      // 用于管理RenderBuffer
    
    GLuint       _positionSlot;     // 用于绑定shader中的Position参数
    GLuint       _colorSlot;        // 用于绑定shader中的SourceColor参数
    
    GLuint       _projectionUniform;
    GLuint       _modelViewUniform;
    GLuint       _currentRotation;
    GLuint       _depthRenderBuffer;
    GLuint       _currentScale;
}

@end

@implementation DAGLView


#pragma mark - private

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentScale = 1.0;
        [self setupGLLayer];
        [self setupGLContext];
        [self setupDepthRenderBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];
//        [self renderVBO];
//        [self render];
    }
    return self;
}

/**
 重写layerClass

 @return layer的类型
 */
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupGLLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES; // layer 默认是透明的 设置为不透明减少性能负荷
}

- (void)setupGLContext {
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_eaglContext) {
        NSLog(@"Failed to initialize OpenGLES context");
        return;
    }
    if (![EAGLContext setCurrentContext:_eaglContext]) {
        NSLog(@"Failed to set current OpenGLES context");
        return;
    }
}

- (void)setupRenderBuffer {
    //创建Render buffer 这个函数会返回一个唯一标识
    glGenRenderbuffers(1, &_colorRenderBuffer);
    //绑定Render buffer 凡是用到GL_RENDERBUFFER 的地方都相当于引用_colorRenderBuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //分配空间给RenderBuffer
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupDepthRenderBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //把render buffer 依附在framebuffer的 GL_COLOR_ATTACHMENT0 位置上面
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)render {
    //设置填充的颜色
    glClearColor(0.0, 0.5, 1.0, 1.0);
    //填色
    glClear(GL_COLOR_BUFFER_BIT);
    //把缓冲区的颜色渲染到视图上去
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderVBO:(CADisplayLink *)displayLink {
    glClearColor(0, 0.5, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h / 2 andTop:h / 2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    
    _currentScale += 0.1;
    if (_currentScale > 6.0) {
        _currentScale = 1.0;
    }
    [modelView scaleBy:CC3VectorMake(_currentScale, _currentScale, 1.0)];
    
    _currentRotation += displayLink.duration * 90;
    [modelView rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];
    
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    //设置UIView中用于渲染的部分
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    //为vertex shader的两个输入参数配置两个合适的值
    /**
     glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
     　  ·indx，顶点数据在着色器程序中的属性
     
     　  ·size，定义这个属性由多少个值组成。譬如说position是由3个float（x,y,z）组成，而颜色是4个float（r,g,b,a）
     
     　　·type，声明每一个值是什么类型。（这例子中无论是位置还是颜色，我们都用了GL_FLOAT）
     
     　　·normalized，指定当被访问时，固定点数据值是否应该被归一化或直接转换成固定点值，这里即GL_FALSE。
     
     　　·stride，指定相邻两个顶点数据之间的偏移量，即间隔大小。OpenGL根据该间隔从由多个顶点数据组成的数据块中跳跃地读取相应的顶点数据。这里vertices数组中仅存储顶点数据（x，y，z），因此相邻两个顶点数据之间的间隔本应为 sizeof(float) 3 。但此处传递默认参数0的原因在于：0表示在顶点数组中每个顶点数据都是紧密排列的，OpenGL会自动计算各个顶点数据的大小得到对应的间隔。
     
     　　·ptr，未使用VBO时，其指向CPU内存中的顶点数据数组，因此这里是vertices.而使用VBO时是这个数据结构的偏移量。表示在这个结构中，从哪里开始获取我们的值。Position的值在前面，所以传0进去就可以了。而颜色是紧接着位置的数据，而position的大小是3个float的大小，所以是从 3 * sizeof(float) 开始的。
     */
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3));
    
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)compileShaders {
    // 加载glsl脚本文件
    NSString *vertexPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    //编译顶点和片段着色器
    GLuint vertexShader = [EAGLUtils compileShaderPath:vertexPath withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [EAGLUtils compileShaderPath:fragmentPath withType:GL_FRAGMENT_SHADER];
    //链接顶点和片段着色器
    GLuint glProgram = glCreateProgram();
    glAttachShader(glProgram, vertexShader);
    glAttachShader(glProgram, fragmentShader);
    glLinkProgram(glProgram);
    
    GLint linkSuccess;
    //检查是否链接成功
    glGetProgramiv(glProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(glProgram, sizeof(messages), 0, &messages[0]);
        NSString *messagesString = [NSString stringWithUTF8String:messages];
        NSLog(@"Failed to link glProgam %@", messagesString);
    }
    //OpenGL真正执行脚本程序
    glUseProgram(glProgram);
    
    //获取脚本变量指针  注意： 名字要和脚本一致
    _positionSlot = glGetAttribLocation(glProgram, "Position");
    _colorSlot = glGetAttribLocation(glProgram, "SourceColor");
    _projectionUniform = glGetUniformLocation(glProgram, "Projection");
    _modelViewUniform = glGetUniformLocation(glProgram, "Modelview");
    //启用数据
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
}



/**
 缓存顶点数据的OpenGL对象
 */
- (void)setupVBOs {
    GLuint vertexBuffer ;
    glGenBuffers(1, &vertexBuffer);
    //绑定 vertexBuffer 指向GL_ARRAY_BUFFER
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    //传递顶点数据到OpenGL-land
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void)setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderVBO:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}




@end
