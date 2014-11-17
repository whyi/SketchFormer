public class GeomHelper {
  public static final float TOLERANCE = 1E-16;
  public static final float dot (PVector v1, PVector v2) {
    return (v1.x*v2.x) + (v1.y*v2.y) + (v1.z*v2.z);
  }
  
  public static final Vector3D cross (Vector3D v1, Vector3D v2) {
    return new Vector3D(v1.y*v2.z-v1.z*v2.y,
                       v1.z*v2.x-v1.x*v2.z,
                       v1.x*v2.y-v1.y*v2.x);    
  }
  
  public static final PVector normalize (PVector vector) {
    float magnitude = sqrt(vector.x*vector.x+vector.y*vector.y+vector.z*vector.z);

    if (magnitude > TOLERANCE &&
        abs(vector.x) > TOLERANCE &&
        abs(vector.y) > TOLERANCE &&
        abs(vector.z) > TOLERANCE) {
          vector /= magnitude;
    }

    return vector;
  }
  
  public static final PVector multiply (PVector vector, float value) {
    vector.x *= value;
    vector.y *= value;
    vector.z *= value;
    return vector;
  }  
}


