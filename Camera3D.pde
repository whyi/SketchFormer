public final float ROTATION_STEP = 0.1f;
public final float PI_DIV_BY_180 = PI/180.0;

public class Camera3D {
  public float zoomFactor = 10;
  private Vector3D rightVector = new Vector3D(1,0,0);
  private Vector3D upVector = new Vector3D(0,1,0);
  private Vector3D viewDir = new Vector3D(0,0,-1);
  private Point3D position;
  private Point3D viewPoint; // viewAt
  private float strafeFactor;
  public float rotatedX = 0;
  public float rotatedY = 0;

  public Camera3D(float x, float y, float z, float strafeFactor) {
    this.position = new Point3D(x, y, z);
    this.strafeFactor = strafeFactor;   
  }
  
  public Camera3D(point3D position, float strafeFactor) {
    this.position = new Point3D(position.x, position.y, position.z);
    this.strafeFactor = strafeFactor;
  }  

  public float disTo(final Point3D point) {
    return (float)sqrt(
      (point.x-x)*(point.x-x)+
      (point.y-y)*(point.y-y)+
      (point.z-z)*(point.z-z));
  }
  
  public void render() {
    beginCamera();
      pushMatrix();
      translate(viewPoint.x, viewPoint.y, viewPoint.z);
      myCamera.rotateAroundOrigin(xDragged, yDragged);
      popMatrix();
      camera(position.x, position.y, position.z, viewDir.x, viewDir.y, viewDir.z, upVector.x, upVector.y, upVector.z);      
    endCamera();
  }

  public void foo() {
    println("rotateAroundOrigin " + x + "," + y);
  }

  public void rotateXX(float angle) {
    // rotate viewDir around the right vector:
    Vector3D tmpV = viewDir.makeScaleBy(cos(angle*PI_DIV_BY_180));
    tmpV.add(upVector.makeScaleBy(sin(angle*PI_DIV_BY_180)));
    tmpV.normalize();

    viewDir = tmpV;
  
    // now compute the new upVector (by CVec::cross product)
    upVector = GeomHelper.cross(viewDir, rightVector);
    upVector.scaleBy(-1);
  }

  public void rotateYY(float angle) {
    // rotate viewDir around the up vector:
    Vector3D tmpV = viewDir.makeScaleBy(cos(angle*PI_DIV_BY_180));
    tmpV.subtract(rightVector.makeScaleBy(sin(angle*PI_DIV_BY_180)));
    tmpV.normalize();

    viewDir = tmpV;
  
    // now compute the new rightVector (by CVec::cross product)
    rightVector = GeomHelper.cross(viewDir, upVector);
  }
  
  public void rotateAroundOrigin(float x, float y) {
    if (x == 0 && y == 0)
      return;

    Vector3D tmp = new Vector3D(
                   GeomHelper.dot(position, rightVector),
                   GeomHelper.dot(position, upVector),
                   GeomHelper.dot(position, viewDir));
  
    //position.set(-viewPoint.x,-viewPoint.y,-viewPoint.z); // go to the origin
    position.set(0,0,0);

    rotateXX(x); // rotateX
    rotateYY(y);
  
    // go back by the recorded vecto
    PVector tempRightVector = new PVector(rightVector.x, rightVector.y, rightVector.z);
    tempRightVector.mult(tmp.x);
    
    PVector tempUpVector = new PVector(upVector.x, upVector.y, upVector.z);
    tempUpVector.mult(tmp.y);
    
    PVector tempViewDir = new PVector(viewDir.x, viewDir.y, viewDir.z);
    tempViewDir.mult(tmp.z);
    PVector positionVector = new PVector(0,0,0);
    positionVector.add(tempRightVector);
    positionVector.add(tempUpVector);
    positionVector.add(tempViewDir);
    position.x = positionVector.x;
    position.y = positionVector.y;
    position.z = positionVector.z;
   
    xDragged = 0;
    yDragged = 0;
    //x*ROTATION_STEP, -y*ROTATION_STEP;
  }
  
  public void viewAt(Point3D point) {
    viewPoint = point;
    position.z = -400;
  }
  
  public void strafeUp() {
    position.y += strafeFactor;
    viewPoint.y += strafeFactor;
  }

  public void strafeDown() {
    position.y -= strafeFactor;
    viewPoint.y -= strafeFactor;
  }

  public void strafeLeft() {
    position.x -= strafeFactor;
    viewPoint.x -= strafeFactor;
  }

  public void strafeRight() {
    position.x += strafeFactor;
    viewPoint.x += strafeFactor;
  }
  
  public void zoomOut() {
    PVector v = new PVector(viewDir.x, viewDir.y, viewDir.z);
    v.mult(-zoomFactor);
    position.x += v.x;
    position.y += v.y;
    position.z += v.z; 
  }
  
  public void zoomIn() {
    PVector v = new PVector(viewDir.x, viewDir.y, viewDir.z);
    v.mult(zoomFactor);
    position.x += v.x;
    position.y += v.y;
    position.z += v.z;    
  }
}
