float sdSphere(vec3 p, vec3 center, float radius)
{
    return length(p - center) - radius;
}

float sdBox(vec3 p, vec3 center, vec3 size)
{
    vec3 d = abs(p - center) - size;
    return max(max(d.x, d.y), d.z);
}

float sdPlaneX(vec3 p, float offset)
{
    return p.x - offset;
}

float sdPlaneY(vec3 p, float offset)
{
    return p.y - offset;
}

float sdPlaneZ(vec3 p, float offset)
{
    return p.z - offset;
}

float sdPlane(vec3 p, vec3 normal, float offset)
{
    return 0.0;
}

