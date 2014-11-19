float xDragged = 0;
float yDragged = 0;
Boolean dragged = false;
PVector dragCoordinate;
Camera3D myCamera = new Camera3D(0,0,-400,100);
Mesh3D mesh = new Mesh3D();

void setup() {
  size(1500, 600, OPENGL); 
  noFill();
  mesh.loadMesh();
  //myCamera.setPositionTo(mesh.geometricCenter);
}

void draw() {
  background(0);
  renderCamera();
  renderMesh();
}

void renderCamera() {
  myCamera.render();
}

void renderMesh() {
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
  private static final String MESH_API_URL = "http://www.whyi.net/bunny.json";
  private PVector[] normals = null;
  private PVector[] vertices = null;
  private Integer[] corners = null;
  private ArrayList opposites = new ArrayList();
  private PVector[] vertexNormals;
  private ArrayList triangleNormals;
  private boolean loaded = false;
  private PVector geometricCenter;
  private PVector minimumCoordinates;
  private PVector maximumCoordinates;
  
  private int numberOfVertices;
  private int numberOfCorners;
  private int numberOfTriangles;

  public Mesh3D() {
    
  }

  public float diag() {
    return sqrt(width()*width()+height()*height());
  }
  
  public float width() {
    return maximumCoordinates.x-minimumCoordinates.x;
  }
  
  public float height() {
    return maximumCoordinates.y-minimumCoordinates.y;
  }

  // in the future load via ajax call!  
  public void loadMesh() {
    String lines[] = loadStrings("bunny.txt");

    int lineCounter = 0;
    numberOfVertices = int(lines[lineCounter]);
    ++lineCounter;

    ArrayList vertexList = new ArrayList();
    for (int i = 0; i < numberOfVertices; ++i) {
      float[] coordinates = float(split(lines[lineCounter], ","));
      PVector point = new PVector(coordinates[0], coordinates[1], coordinates[2]);
      vertexList.add(point);
      ++lineCounter;
    }

    numberOfTriangles = int(lines[lineCounter]);
    ++lineCounter;

    ArrayList<Integer> cornerList = new ArrayList();

    for (int i = 0; i < numberOfTriangles; ++i) {
      int[] faceIndices = int(split(lines[lineCounter], ","));
      ++lineCounter;
      // assert here maybe
      cornerList.add(faceIndices[0]);
      cornerList.add(faceIndices[1]);
      cornerList.add(faceIndices[2]);
    }

    vertices = (PVector[])vertexList.toArray();
    numberOfVertices = vertices.length;

    corners = (Integer[])cornerList.toArray();
    numberOfCorners = corners.length;
 
    geometricCenter = computeGeometricCenter();
    computeBoundingBox();
    computeNormals();
    loaded = true;
  }

 
  public void render() {
    if (loaded == false)
      return;

    directionalLight(126, 126, 126, 0, 0, -1);
    ambientLight(255, 0, 0);

    lights();
    
    fill(0,255,0);
    
    stroke();

    for (int i = 0; i < numberOfTriangles; ++i) {
      PVector a = vertices[corners[i*3]];
      PVector normalA = vertexNormals[corners[i*3]]; 
      PVector b = vertices[corners[i*3+1]];
      PVector normalB = vertexNormals[corners[i*3+1]];
      PVector c = vertices[corners[i*3+2]];
      PVector normalC = vertexNormals[corners[i*3+2]];

      beginShape(TRIANGLES);
        normal(normalA.x, normalA.y, normalA.z);
        vertex(a.x, a.y, a.z);
        normal(normalB.x, normalB.y, normalB.z);
        vertex(b.x, b.y, b.z);
        normal(normalC.x, normalC.y, normalC.z);
        vertex(c.x, c.y, c.z);
      endShape();
    }
    pushMatrix();
      noStroke();
      sphere(0);
    popMatrix();
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
  
  // shortcuts from corner index to geometry
  private PVector g(int cornerIndex) {
    return vertices[corners[cornerIndex]];
  }
  
  // shortcut to corner
  private Integer v(Integer cornerIndex) {
    return corners[cornerIndex];
  }
  
  // shortcut from vertex index to triangle index
  private int t(int cornerIndex) {
    return (int)cornerIndex/3;
  }
  
  private void computeNormals() {
    triangleNormals = new ArrayList();

    // caches normals of all triangles.
    for (int i = 0; i < numberOfTriangles; ++i) {
      PVector triangleNormal = triNormal(g(i*3), g(i*3+1), g(i*3+2));
      triangleNormal.normalize();
      triangleNormals.add(triangleNormal);
    }

    // computes the vertex normals as sums of the normal vectors of incident triangles scaled by area/2
    vertexNormals = new PVector[numberOfVertices];
  
    for (int i=0; i<numberOfVertices; ++i) {
      vertexNormals[i] = new PVector(0,0,0);
    }
  
    for (int i=0; i<numberOfCorners; ++i) {
      vertexNormals[v(i)].add((PVector)triangleNormals.get((int)t(i)));
    }

    for (PVector vertexNormal: vertexNormals) {
      vertexNormal.normalize();
    }
  }
 
  private PVector vector(PVector A, PVector B) {
    return new PVector(B.x-A.x, B.y-A.y, B.z-A.z);
  }
 
  private PVector triNormal(PVector A, PVector B, PVector C) {
    PVector AB = vector(A,B);
    PVector AC = vector(A,C);
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

