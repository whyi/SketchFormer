public class Vector3D {
  float x, y, z;

  public Vector3D(Point3D A, Point3D B) {
    this.x = B.x-A.x;
    this.y = B.y-A.y;
    this.z = B.z-A.z;
  }
  
  public Vector3D(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  float dot (Vector3D vector) {
    return (this.x*vector.x) + (this.y*vector.y) + (this.z*vector.z);
  }
  
  public void normalize() {
    final float factor = sqrt(x*x+y*y+z*z);
    x /= factor;
    y /= factor;
    z /= factor;    
  }

  public void scaleBy(float factor) {
    x *= factor;
    y *= factor;
    z *= factor;
  }
  
  public Vector3D makeScaleBy(float factor) {
    return new Vector3D(x*factor, y*factor, z*factor);
  }
  
  public void add(Vector3D vector) {
    x += vector.x;
    y += vector.y;
    z += vector.z;
  }
  
  public void subtract(Vector3D vector) {
    x -= vector.x;
    y -= vector.y;
    z -= vector.z;
  }  
  
  public String toString() {
    return new String("(" + x + "," + y + "," + z + ")");
  }  
}
