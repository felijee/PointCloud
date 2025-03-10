// Vertex Shader

uniform sampler2D positions;
uniform vec2 nearFar;
uniform float pointSize;

varying float size;
varying vec3 vPos; // Pass the particle's world position to the fragment shader

void main() {
    // Sample the particle position from the texture
    vec3 pos = texture2D(positions, position.xy).xyz;
    vPos = pos;  // Store the position for the fragment shader

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    
    // Set the point size (and pass the size along as a varying)
    gl_PointSize = size = max(1.0, (step(1.0 - (1.0 / 512.0), position.x)) * pointSize);
}
