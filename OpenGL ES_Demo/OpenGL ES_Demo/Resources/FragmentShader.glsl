
varying mediump vec4 DestionationColor;
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main(void) {
    gl_FragColor = DestionationColor * texture2D(Texture, TexCoordOut);
}
