float xDragged = 0;
float yDragged = 0;
bool dragged = false;
PVector dragCoordinate;
Camera3D myCamera = new Camera3D(0,0,0,100);
Mesh3D mesh = new Mesh3D();

void setup() {
  size(1500, 600, P3D); 
  noFill();
  mesh.loadMesh();
  myCamera.setPositionTo(mesh.geometricCenter);
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
  private PVector rightVector = new PVector(1,0,0);
  private PVector upVector = new PVector(0,1,0);
  private PVector viewDir = new PVector(0,0,-1);
  private PVector position;
  private PVector viewPoint; // viewAt
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

  public float disTo(final PVector point) {
    return (float)sqrt(
      (point.x-x)*(point.x-x)+
      (point.y-y)*(point.y-y)+
      (point.z-z)*(point.z-z));
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
  
  public void setPositionTo(PVector point) {
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
  private PVector[] normals = null;
  private PVector[] vertices = null;
  private int[] corners = null;
  private ArrayList opposites = new ArrayList();
  private boolean loaded = false;
  private PVector geometricCenter;
  private PVector minimumCoordinates;
  private PVector maximumCoordinates;

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
      PVector point = new PVector(coordinates[0], coordinates[1], coordinates[2]);
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
      PVector a = vertices[corners[i*3]];
      PVector b = vertices[corners[i*3+1]];
      PVector c = vertices[corners[i*3+2]];
      beginShape(TRIANGLE);
        vertex(a.x, a.y, a.z);
        vertex(b.x, b.y, b.z);
        vertex(c.x, c.y, c.z);
      endShape(TRIANGLE);
    }    
  }
  
  public PVector computeGeometricCenter() {
    PVector pt = new PVector(0,0,0);
    for (PVector point : vertices) {
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
    minimumCoordinates = new PVector(1E+16,1E+16,1E+16);
    maximumCoordinates = new PVector(-1E+16,-1E+16,-1E+16);

    PVector pt = new PVector(0,0,0);
    for (PVector point : vertices) {
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
  
  PVector triNormal(PVector A, PVector B, PVector C) {
    PVector AB = B.sub(A);
    PVector AC = C.sub(A);
    return AB.cross(AC);
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
  dragCoordinate = new PVector(mouseX, mouseY, 0);
}

void mouseDragged() {
  if (mousePressed) {
    yDragged = mouseX - dragCoordinate.x;
    xDragged = mouseY - dragCoordinate.y;
    dragCoordinate = new PVector(mouseX, mouseY, 0);
    dragged = true;
  }
}

void mouseReleased() {
  if (dragged) {
    yDragged = mouseX - dragCoordinate.x;
    xDragged = mouseY - dragCoordinate.y;
    dragCoordinate = new PVector(mouseX, mouseY, 0);
    dragged = false;
  }
}


