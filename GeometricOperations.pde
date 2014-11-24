// This probably doesn't make sense to be regular class,
// as static final class make more sense here.
// However Jasmine cannot deal with it, so it's for testibility purpose only.
public static class GeometricOperations {
  public static PVector midPt(PVector point1, PVector point2) {
    PVector point = new PVector(point1.x + point2.x, point1.y + point2.y, point1.z + point2.z);
    point.div(2);
    return point;
  }
  
  public static PVector vector(PVector A, PVector B) {
    return new PVector(B.x-A.x, B.y-A.y, B.z-A.z);
  }
 
  public static PVector triNormal(PVector A, PVector B, PVector C) {
    PVector AB = vector(A,B);
    PVector AC = vector(A,C);
    PVector normal = AB.cross(AC);
    normal.normalize();
    return normal;
  }  
}

