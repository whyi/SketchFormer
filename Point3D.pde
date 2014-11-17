public class Point3D {
  private float x, y, z;

  public Point3D (float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public float disTo (Point3D point) {
    return (float)sqrt(
      (point.x-x)*(point.x-x)+
      (point.y-y)*(point.y-y)+
      (point.z-z)*(point.z-z));
  }
  
  public String toString() {
    return new String("(" + x + "," + y + "," + z + ")");
  }
  
  public void set(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}
