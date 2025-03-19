// Fragment Shader

uniform vec3 small;  // Unused
uniform vec3 big;    // Unused

varying float size;
varying vec3 vPos;   // World position from vertex shader

void main() {
    // Distance from center
    float d = length(vPos);

    // Define the four colors in the gradient
    vec3 colorB = vec3(0.529, 0.961, 0.961);  // Light blue
    vec3 colorA = vec3(0.000, 0.000, 1.000);  // Blue
    vec3 colorD = vec3(0.980, 0.216, 0.784);  // Pink
    vec3 colorC = vec3(0.569, 0.216, 0.765);  // Purple

    // Remap distance to a value between 0.0 and 1.0 over a wider range
    float t = clamp((d - 100.0) / 60.0, 0.0, 1.0);

    vec3 gradientColor;

    // Divide the range into three segments
    if (t < 0.33) {
        float t1 = t / 0.33;
        gradientColor = mix(colorA, colorB, t1);
    } else if (t < 0.66) {
        float t2 = (t - 0.33) / 0.33;
        gradientColor = mix(colorB, colorC, t2);
    } else {
        float t3 = (t - 0.66) / 0.34;
        gradientColor = mix(colorC, colorD, t3);
    }

    // Radial falloff for larger points
    if (size > 1.0) {
        float falloff = 1.0 - length(gl_PointCoord.xy - vec2(0.5));
        gl_FragColor = vec4(gradientColor * falloff * 1.5, 0.95);
    } else {
        gl_FragColor = vec4(gradientColor, 1.0);
    }
}
