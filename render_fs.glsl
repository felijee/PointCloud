// Fragment Shader

uniform vec3 small;  // (Unused in this example but kept for reference)
uniform vec3 big;    // (Unused in this example but kept for reference)

varying float size;
varying vec3 vPos;   // Received world position from the vertex shader

void main() {
    // Calculate the distance from the particle's position to the origin
    float d = length(vPos);

    // Define the base colors for the gradient
    vec3 lightblue = vec3(0.529, 0.961, 0.961);
    vec3 lightgreen = vec3(0.059, 0.961, 0.647);
    vec3 blue = vec3(0.000, 0.000, 1.000);
    vec3 red = vec3(0.902, 0.157, 0.314);
    vec3 pink = vec3(0.980, 0.216, 0.784);
    vec3 purple = vec3(0.569, 0.216, 0.765);


    // Compute a factor for interpolation.
    // Here we use a 10-unit range above 130 to transition from blue to pink:
    //   t = 0 when d <= 130, and t = 1 when d >= 140.
    float t = clamp((d - 130.0) / 10.0, 0.0, 1.0);
    
    // Mix the colors based on the distance factor.
    vec3 gradientColor = mix(purple, blue, t);
    
    // Optionally, you can also modulate the point's brightness with gl_PointCoord 
    // to get a radial falloff. For larger points, apply the falloff.
    if (size > 1.0) {
        gl_FragColor = vec4(gradientColor * (1.0 - length(gl_PointCoord.xy - vec2(0.5))) * 1.5, 0.95);
    } else {
        gl_FragColor = vec4(gradientColor, 0.6);
    }
}
