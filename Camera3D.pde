public final float ROTATION_STEP = 0.1f;
public final float PI_DIV_BY_180 = PI/180.0;

public class Camera3D {
  public float zoomFactor = 10;
  private PVector rightVector = new PVector(1,0,0);
  private PVector upVector = new PVector(0,1,0);
  private PVector viewDir = new PVector(0,0,-1);
  private PVector position;
  private Point3D viewPoint; // viewAt
  private float strafeFactor;
  public float rotatedX = 0;
  public float rotatedY = 0;

  public Camera3D(float x, float y, float z, float strafeFactor) {
    this.position = new PVector(x, y, z);
    this.strafeFactor = strafeFactor;   
  }
  
  public Camera3D(PVector position, float strafeFactor) {
    this.position = position;
    this.strafeFactor = strafeFactor;
  }  

  public void setPositionTo(PVector position) {
    this.position = position;
  }

  public void render() {
    beginCamera();
      myCamera.rotateAroundOrigin(xDragged, yDragged);
      camera(position.x, position.y, position.z, viewDir.x, viewDir.y, viewDir.z, upVector.x, upVector.y, upVector.z);      
    endCamera();
  }

  public void rotateAroundXAxis(float angle) {
    // rotate viewDir around the right vector:
    PVector viewDirComponent = getViewDirComponent(angle);
    PVector upVectorComponent = upVector.get();
    upVectorComponent.mult(sin(angle*PI_DIV_BY_180));
    
    viewDirComponent.add(upVectorComponent);
    viewDirComponent.normalize();

    viewDir.set(viewDirComponent);

    // now compute the new upVector (by CVec::cross product)
    upVector = viewDir.cross(rightVector);
    upVector.mult(-1);
  }

  public void rotateAroundYAxis(float angle) {
    // rotate viewDir around the up vector:
    PVector viewDirComponent = getViewDirComponent(angle);
    PVector rightVectorComponent = rightVector.get();
    rightVectorComponent.mult(sin(angle*PI_DIV_BY_180));

    viewDirComponent.sub(rightVectorComponent);
    viewDirComponent.normalize();

    viewDir.set(viewDirComponent);
 
    // now compute the new rightVector (by CVec::cross product)
    rightVector = viewDir.cross(upVector);
  }
  
  public void rotateAroundOrigin(float x, float y) {
    if (x == 0 && y == 0)
      return;

    PVector previousComponents = new PVector(position.dot(rightVector), position.dot(upVector), position.dot(viewDir));
    position.set(0,0,0);

    rotateAroundXAxis(x);
    rotateAroundYAxis(y);
  
    // go back by the recorded vecto
    PVector tempRightVector = rightVector.get();
    tempRightVector.mult(previousComponents.x);
    
    PVector tempUpVector = upVector.get();
    tempUpVector.mult(previousComponents.y);
    
    PVector tempViewDir = viewDir.get();
    tempViewDir.mult(previousComponents.z);

    position.add(tempRightVector);
    position.add(tempUpVector);
    position.add(tempViewDir);
   
    xDragged = 0;
    yDragged = 0;
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
  
  private PVector getViewDirComponent(float angle) {
    PVector viewDirComponent = viewDir.get();
    viewDirComponent.mult(cos(angle*PI_DIV_BY_180));
    return viewDirComponent;
  }
}