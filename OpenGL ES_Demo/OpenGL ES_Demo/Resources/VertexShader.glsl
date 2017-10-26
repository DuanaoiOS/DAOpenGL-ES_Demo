attribute vec4 Position;
attribute vec4 SourceColor;

uniform mat4 Projection;
uniform mat4 Modelview;

varying vec4 DestionationColor;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void) {
    DestionationColor = SourceColor;
    gl_Position =  Projection * Modelview * Position;
    TexCoordOut = TexCoordIn;
}
