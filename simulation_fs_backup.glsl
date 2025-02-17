varying vec2 vUv;
uniform sampler2D texture;
uniform float timer;
uniform float frequency;
uniform float amplitude;
uniform float maxDistance;
uniform mat3 objectRotation;


// Uniforms for cursor displacement (using x/y only)
uniform vec3 cursor;
uniform float cursorRadius;
uniform float cursorStrength;

// New uniforms for the cursor-based noise (stronger but lower frequency)
uniform float cursorNoiseFrequency; // e.g., 0.005
uniform float cursorNoiseAmplitude; // e.g., 60

// New uniform for smoothing (lerp factor)
uniform float smoothing; // a value between 0.0 and 1.0 (e.g., 0.1)

//
// --- Noise functions & curl() remain the same ---
//
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 permute(vec3 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}
float noise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                          0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                         -0.577350269189626,  // -1.0 + 2.0 * C.x
                          0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
                    + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

vec3 curl(float x, float y, float z) {
    float eps = 1.0, eps2 = 2.0 * eps;
    float n1, n2, a, b;
    // animate the noise field with the timer
    x += timer * 0.05;
    y += timer * 0.05;
    z += timer * 0.05;
    vec3 curl = vec3(0.0);
    n1 = noise(vec2(x, y + eps));
    n2 = noise(vec2(x, y - eps));
    a = (n1 - n2) / eps2;
    n1 = noise(vec2(x, z + eps));
    n2 = noise(vec2(x, z - eps));
    b = (n1 - n2) / eps2;
    curl.x = a - b;
    n1 = noise(vec2(y, z + eps));
    n2 = noise(vec2(y, z - eps));
    a = (n1 - n2) / eps2;
    n1 = noise(vec2(x + eps, z));
    n2 = noise(vec2(x - eps, z));
    b = (n1 - n2) / eps2;
    curl.y = a - b;
    n1 = noise(vec2(x + eps, y));
    n2 = noise(vec2(x - eps, y));
    a = (n1 - n2) / eps2;
    n1 = noise(vec2(y + eps, z));
    n2 = noise(vec2(y - eps, z));
    b = (n1 - n2) / eps2;
    curl.z = a - b;
    return curl;
}

void main() {
    // Get the previous position from the texture
    vec3 pos = texture2D(texture, vUv).xyz;

    // Base floating using subtle curl noise
    vec3 tar = pos + curl(pos.x * frequency, pos.y * frequency, pos.z * frequency) * amplitude;
    float d = length(pos - tar) / maxDistance;
    vec3 displacedPos = mix(pos, tar, pow(d, 5.0));

    // --- Additional Cursor Displacement (based solely on x/y) ---
    vec2 diffXY = displacedPos.xy - cursor.xy;
    float distXY = length(diffXY);
    float falloff = 1.0 - smoothstep(0.0, cursorRadius, distXY);
    
    // Compute an extra noise term for the cursor with lower frequency/higher amplitude
    vec3 cursorNoise = curl(displacedPos.x * cursorNoiseFrequency,
                            displacedPos.y * cursorNoiseFrequency,
                            displacedPos.z * cursorNoiseFrequency)
                        * cursorNoiseAmplitude;
    // Apply the falloff (ignoring z difference)
    vec3 cursorDisp = cursorNoise * falloff;
    
    // Combine base displacement with mouse effect
    vec3 computedTarget = displacedPos + cursorDisp;
    
    // Smoothly interpolate from the previous position to the new target
    vec3 newPos = mix(pos, computedTarget, smoothing);
    
    gl_FragColor = vec4(newPos, 1.0);
}
