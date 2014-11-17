float xDragged = 0;
float yDragged = 0;
bool dragged = false;
Point3D dragCoordinate;
Camera3D myCamera = new Camera3D(0,0,0,100);
Mesh3D mesh = new Mesh3D();

void setup() {
  size(1500, 600, P3D); 
  noFill();
  mesh.loadMesh();
  myCamera.viewAt(mesh.geometricCenter);
}

void draw() {
  background(0);
  renderCamera();
  renderGeo();
}

void renderCamera() {
  myCamera.render();
}

void renderGeo() {
  pushMatrix();
    translate(-mesh.geometricCenter.x, -mesh.geometricCenter.y, -mesh.geometricCenter.z);
    mesh.render();
  popMatrix();
}
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


void keyPressed() {
  if (keyCode == 'w' || keyCode == 'W') {
    myCamera.strafeUp();
  }
  
  if (keyCode == 's' || keyCode == 'S') {
    myCamera.strafeDown();
  }
  
  if (keyCode == 'a' || keyCode == 'A') {
    myCamera.strafeLeft();
  }
  
  if (keyCode == 'd' || keyCode == 'D') {
    myCamera.strafeRight();
  }
}

public class Mesh3D {
  private static final string MESH_API_URL = "http://www.whyi.net/bunny.json";
  private Point3D[] normals = null;
  private Point3D[] vertices = null;
  private int[] corners = null;
  private ArrayList opposites = new ArrayList();
  private boolean loaded = false;
  private Point3D geometricCenter;
  private Point3D minimumCoordinates;
  private Point3D maximumCoordinates;

  public Mesh3D() {
    
  }

  public float diag() {
    sqrt(width()*width()+height()*height());
  }
  
  public float width() {
    return maximumCoordinates.x-minimumCoordinates.x;
  }
  
  public float height() {
    return maximumCoordinates.y-minimumCoordinates.y;
  }

  // in the future load via ajax call!  
  public void loadMesh(String filename) {
    String lines[] = loadStrings("bunny.txt");

    int lineCounter = 0;
    int numberOfVertices = int(lines[lineCounter]);
    ++lineCounter;

    ArrayList vertexList = new ArrayList();
    for (int i = 0; i < numberOfVertices; ++i) {
      float[] coordinates = float(split(lines[lineCounter], ","));
      Point3D point = new Point3D(coordinates[0], coordinates[1], coordinates[2]);
      vertexList.add(point);
      ++lineCounter;
    }

    int numberOfFaces = int(lines[lineCounter]);
    ++lineCounter;

    ArrayList cornerList = new ArrayList();

    for (int i = 0; i < numberOfFaces; ++i) {
      int[] faceIndices = int(split(lines[lineCounter], ","));
      ++lineCounter;
      // assert here maybe
      cornerList.add(faceIndices[0]);
      cornerList.add(faceIndices[1]);
      cornerList.add(faceIndices[2]);
    }

    corners = cornerList.toArray();
    vertices = vertexList.toArray();
    geometricCenter = computeGeometricCenter();
    computeBoundingBox();
    loaded = true;
  }
  
  public void render() {
    if (loaded == false)
      return;
    
    // origin
    pushMatrix();
      translate(0,0,0);
      box(1);
    popMatrix();
    
    fill(0,255,0);    
    for (int i = 0; i < corners.length/3; ++i) {
      Point3D a = vertices[corners[i*3]];
      Point3D b = vertices[corners[i*3+1]];
      Point3D c = vertices[corners[i*3+2]];
      beginShape(TRIANGLE);
        vertex(a.x, a.y, a.z);
        vertex(b.x, b.y, b.z);
        vertex(c.x, c.y, c.z);
      endShape(TRIANGLE);
    }    
  }
  
  public Point3D computeGeometricCenter() {
    Point3D pt = new Point3D(0,0,0);
    for (Point3D point : vertices) {
      pt.x += point.x;
      pt.y += point.y;
      pt.z += point.z;
    }
    
    int numberOfVertices = vertices.length;
    pt.x /= numberOfVertices;
    pt.y /= numberOfVertices;
    pt.z /= numberOfVertices;
    return pt;
  }

  public void computeBoundingBox() {
    minimumCoordinates = new Point3D(1E+16,1E+16,1E+16);
    maximumCoordinates = new Point3D(-1E+16,-1E+16,-1E+16);

    Point3D pt = new Point3D(0,0,0);
    for (Point3D point : vertices) {
      if (point.x < minimumCoordinates.x) {
        minimumCoordinates.x = point.x;
      }
      
      if (point.y < minimumCoordinates.y) {
        minimumCoordinates.y = point.y;
      }

      if (point.z < minimumCoordinates.z) {
        minimumCoordinates.z = point.z;
      }

      if (point.x > maximumCoordinates.x) {
        maximumCoordinates.x = point.x;
      }
      
      if (point.y > maximumCoordinates.y) {
        maximumCoordinates.y = point.y;
      }

      if (point.z > maximumCoordinates.z) {
        maximumCoordinates.z = point.z;
      }
    }
  }
  
  private void computeNormal() {
    if (normals == null) {
      
    }
  }
  
  private void computeOpposites() {
    
  }
}
void mouseScrolled() {
   if (mouseScroll > 0) {
     myCamera.zoomIn();
   }
   else {
     myCamera.zoomOut();
   }
}

void mousePressed() {
  dragged = false;
  dragCoordinate = new Point3D(mouseX, mouseY, 0);
}

void mouseDragged() {
  if (mousePressed) {
    yDragged = mouseX - dragCoordinate.x;
    xDragged = mouseY - dragCoordinate.y;
    dragCoordinate = new Point3D(mouseX, mouseY, 0);
    dragged = true;
  }
}

void mouseReleased() {
  if (dragged) {
    yDragged = mouseX - dragCoordinate.x;
    xDragged = mouseY - dragCoordinate.y;
    dragCoordinate = new Point3D(mouseX, mouseY, 0);
    dragged = false;
  }
}

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

