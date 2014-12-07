float xDragged = 0;
float yDragged = 0;
Boolean dragged = false;
PVector dragCoordinate;
public Camera myCamera = new Camera(0,0,-400,100);
public GeometricOperations geometricOperations = new GeometricOperations();
public OTableHelper myOTableHelper = new OTableHelper();
public Mesh mesh = new Mesh(geometricOperations, myOTableHelper);

public Mesh getMesh() {
  return mesh;
}

public GeometricOperations getGeometricOperations() {
  return geometricOperations;
}

public OTableHelper getOTableHelper() {
  return myOTableHelper;
}

void setup() {
  size(1500, 600, OPENGL); 
  noFill();
  mesh.loadMesh();
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

public class Camera {
  public float zoomFactor = 10;
  private PVector rightVector = new PVector(1,0,0);
  private PVector upVector = new PVector(0,1,0);
  private PVector viewDir = new PVector(0,0,-1);
  private PVector position;
  private PVector viewPoint; // viewAt
  private float strafeFactor;
  public float rotatedX = 0;
  public float rotatedY = 0;

  public Camera(float x, float y, float z, float strafeFactor) {
    this.position = new PVector(x, y, z);
    this.strafeFactor = strafeFactor;   
  }
  
  public Camera(PVector position, float strafeFactor) {
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
  
  public void viewAt(PVector point) {
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
  
  if (keyCode == 'q' || keyCode == 'Q') {
    mesh.refine();
  }  
}

import java.util.Collections;
public class Mesh {
  private static final int BOUNDARY;
  private static final String MESH_API_URL = "http://www.whyi.net/bunny.json";
  private ArrayList<PVector> vertices = null;
  private ArrayList<Integer> corners = null;
  private ArrayList<Integer> opposites = null;
  private ArrayList<PVector> vertexNormals = null;
  private ArrayList<PVector> triangleNormals = null;
  private Integer[] temporaryCorners = null;
  private boolean loaded = false;
  private PVector geometricCenter;
  private PVector minimumCoordinates;
  private PVector maximumCoordinates;
  
  private int numberOfVertices;
  private int numberOfCorners;
  private int numberOfTriangles;
  private final GeometricOperations geometricOperations;
  private final OTableHelper myOTableHelper;
  
  public Mesh(GeometricOperations geometricOperations, OTableHelper myOTableHelper) {
    this.geometricOperations = geometricOperations;
    this.myOTableHelper = myOTableHelper;
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

    vertices = new ArrayList();
    for (int i = 0; i < numberOfVertices; ++i) {
      float[] coordinates = float(split(lines[lineCounter], ","));
      PVector point = new PVector(coordinates[0], coordinates[1], coordinates[2]);
      vertices.add(point);
      ++lineCounter;
    }

    numberOfTriangles = int(lines[lineCounter]);
    ++lineCounter;

    corners = new ArrayList();

    for (int i = 0; i < numberOfTriangles; ++i) {
      int[] faceIndices = int(split(lines[lineCounter], ","));
      ++lineCounter;

      corners.add(faceIndices[0]);
      corners.add(faceIndices[1]);
      corners.add(faceIndices[2]);
    }

    numberOfVertices = vertices.size();
    numberOfCorners = corners.size();

    geometricCenter = computeGeometricCenter();
    computeBoundingBox();
    computeNormals();
    buildOTable();
    loaded = true;
  }

 
  public void render() {
    if (!loaded)
      return;

    directionalLight(126, 126, 126, 0, 0, -1);
    ambientLight(255, 0, 0);

    lights();
    
    fill(0,255,0);
    
    stroke(3);

    for (int i = 0; i < numberOfTriangles; ++i) {
      PVector a = g(i*3);
      PVector normalA = vertexNormal(i*3); 
      PVector b = g(i*3+1);
      PVector normalB = vertexNormal(i*3+1);
      PVector c = g(i*3+2);
      PVector normalC = vertexNormal(i*3+2);

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
    for (PVector point : (ArrayList<PVector>)vertices) {
      pt.x += point.x;
      pt.y += point.y;
      pt.z += point.z;
    }
    
    int numberOfVertices = vertices.size();
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
    return vertices.get(v(cornerIndex));
  }

  // shortcut from corner index to vertex normal
  private PVector vertexNormal(int cornerIndex) {
    return vertexNormals.get(v(cornerIndex));
  }
  
  // shortcut to corner
  private int v(int cornerIndex) {
    return corners.get(cornerIndex);
  }
  
  // shortcut from vertex index to triangle index
  private int t(int cornerIndex) {
    return floor(cornerIndex/3);
  }
  
  // shortcut to the next corner
  private int n(int cornerIndex) {
    if (cornerIndex%3 == 2) {
      return cornerIndex-2;
    }
    return cornerIndex+1;
  }

  // shortcut to the previous corner
  private int p(int cornerIndex) {
    if (cornerIndex%3 == 0) {
      return cornerIndex+2;
    }
    return cornerIndex-1;
  }

  // shortcut to the opposite
  private int o(int cornerIndex) {
    return opposites.get(cornerIndex);
  }

  // shortcut to the left corner
  private int leftOf(int cornerIndex) {
    return o(n(cornerIndex));
  }
  
  // shortcut to the right corner
  private int rightOf(int cornerIndex) {
    return o(p(cornerIndex));
  }
  
  private boolean isBorder(int cornerIndex) {
    return o(cornerIndex) == BOUNDARY;
  }
 
  private void computeNormals() {
    triangleNormals = new ArrayList();

    // caches normals of all triangles.
    for (int i = 0; i < numberOfTriangles; ++i) {
      PVector triangleNormal = geometricOperations.triNormal(g(i*3), g(i*3+1), g(i*3+2));
      triangleNormal.normalize();
      triangleNormals.add(triangleNormal);
    }

    // computes the vertex normals as sums of the normal vectors of incident triangles scaled by area/2
    vertexNormals = new ArrayList();
  
    for (int i=0; i<numberOfVertices; ++i) {
      vertexNormals.add(new PVector(0,0,0));
    }
  
    for (int i=0; i<numberOfCorners; ++i) {
      PVector vertexNormal = (PVector) vertexNormals.get(v(i));
      vertexNormal.add((PVector)triangleNormals.get((int)t(i)));
      vertexNormals.set(v(i), vertexNormal);
    }

    for (PVector vertexNormal: vertexNormals) {
      vertexNormal.normalize();
    }
  }

  // O(n^2) to O(nlogn) magic!
  private void buildOTable() {
    opposites = new ArrayList();

    for (int i=0; i<numberOfCorners; ++i) {
      opposites.add(-1);
    }
  
    // couldn't use Guava here, so let's keep the old Triplet class.
    ArrayList triples = new ArrayList();
    for (int i=0; i<numberOfCorners; ++i) {
      int nextCorner = v(n(i));
      int previousCorner = v(p(i));
      
      triples.add(new Triplet(min(nextCorner,previousCorner), max(nextCorner,previousCorner), i));
    }

    myOTableHelper.naiveSort(triples);
  
    // just pair up the stuff
    for (int i = 0; i < numberOfCorners-1; ++i) {
      Triplet t1 = (Triplet)triples.get(i);
      Triplet t2 = (Triplet)triples.get(i+1);
      if (t1.a == t2.a && t1.b == t2.b) {
        opposites.set(t1.c, t2.c);
        opposites.set(t2.c, t1.c);
        ++i;
      }
    }
  }

  public void refine() {
    console.log("splitting " + numberOfTriangles);
    temporaryCorners = new Integer[numberOfTriangles*12];
    // FIXME : initializing with the size doesn't work.
    splitEdges();
    console.log("done!");
    console.log("bulging");
    bulge();
    console.log("done!");
    console.log("spliting triangles");
    splitTriangles();
    console.log("done!");
  }

  public void splitEdges() {
    // for each corner
    for (int corner=0; corner<numberOfCorners; ++corner) {
      if (isBorder(corner)) {
        vertices.add(geometricOperations.midPt(g(n(corner)), g(p(corner))));
        temporaryCorners[corner] = vertices.size()-1;
      }
      else {
        // if this corner is the first to see the edge
        if (corner < o(corner)) {
          vertices.add(geometricOperations.midPt(g(n(corner)), g(p(corner))));
          temporaryCorners[o(corner)] = vertices.size()-1;
          temporaryCorners[corner] = vertices.size()-1;
        }
      }
    }
    numberOfVertices = vertices.size();
  }

  // Bulge Operation does the following:
  private void bulge() {
    for (int corner = 0; corner < numberOfCorners; corner++) {
      // no tweak for mid-vertices of border edges
      final int oppositeCorner = o(corner);
      final int previousCorner = p(corner);
      final int nextCorner = n(corner);
      if (!isBorder(corner) &&
        corner < oppositeCorner &&
        !isBorder(previousCorner) && 
        !isBorder(nextCorner) &&
        !isBorder(p(oppositeCorner)) &&
        !isBorder(n(oppositeCorner))) {
        final PVector vertex = vertices.get(temporaryCorners[corner]);
        final PVector neighboringVector = geometricOperations.midPt(g(leftOf(corner)),g(rightOf(corner)));
        final PVector farNeighboringVector = geometricOperations.midPt(g(leftOf(oppositeCorner)),g(rightOf(oppositeCorner)));
        final PVector midNeighboringVector = geometricOperations.midPt(neighboringVector, farNeighboringVector);
        final PVector oppositeVector = geometricOperations.midPt(g(corner), g(oppositeCorner));
        final PVector vectorToAdd = geometricOperations.vector(oppositeVector, midNeighboringVector);
        vectorToAdd.mult(0.25);
        vertex.add(vectorToAdd);
      }
    }
  }

  private void splitTriangles(void) {
    for (int corner = 0; corner < numberOfCorners; corner+=3) {
      int cornerIndex = 3*numberOfTriangles+corner;
      corners.set(cornerIndex, v(corner));
      corners.set(n(cornerIndex), temporaryCorners[p(corner)]);
      corners.set(p(cornerIndex), temporaryCorners[n(corner)]);
      
      int cornerIndex = 6*numberOfTriangles;
      corners.set(cornerIndex, v(corner));
      corners.set(n(cornerIndex), temporaryCorners[p(corner)]);
      corners.set(p(cornerIndex), temporaryCorners[n(corner)]);      
     
      V[6*nt+i] = v(n(i));
      V[n(6*nt+i)]=w(i)
      V[p(6*nt+i)]=w(p(i));
      
      V[9*nt+i] = v(p(i)); V[n(9*nt+i)]=w(n(i)); V[p(9*nt+i)]=w(i);
      V[i]=w(i); V[n(i)]=w(n(i)); V[p(i)]=w(p(i));
    }
    nt = 4*nt;
    nc = 3*nt;
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

public class OTableHelper {
  private void swap(ArrayList list, int a, int b) {
    Triplet tmp = (Triplet) list.get(a);
    list.set(a, list.get(b));
    list.set(b, tmp);
  }

  private int partition(ArrayList list, int left, int right) {
    int pivotIndex = floor((left + right)/2);
    final Triplet pivotValue = (Triplet) list.get(pivotIndex);
    swap(list, pivotIndex, right);

    int storedIndex = left;
    for (int i=left; i<right; ++i) {
      Triplet currentValue = (Triplet) list.get(i);
      if (currentValue.isLessThan(pivotValue)) {
        swap(list, storedIndex, i);
        ++storedIndex;
      }
    }
    swap(list, right, storedIndex);
    return storedIndex;
  }
  
  private ArrayList naiveQuickSort(ArrayList list, int left, int right) {
    if (left < right) {
      final int pivot = partition(list, left, right);
      naiveQuickSort(list, left, pivot-1);
      naiveQuickSort(list, pivot+1, right);
    }
    return list;
  }

  public ArrayList naiveSort(ArrayList list) {
    return naiveQuickSort(list, 0, list.size()-1);
  }
}
public final class Triplet {
  public final int a;
  public final int b;
  public final int c;
  public Triplet(int a, int b, int c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }
 
  public boolean isLessThan(Triplet rhs) {
    if (a < rhs.a) {
      return true;
    }
    else if (a == rhs.a) {
      if (b < rhs.b) {
        return true;
      }
      else if (b == rhs.b) {
        if (c < rhs.c) {
          return true;
        }
      }
      else {
        return false;
      }
    }
    return false;
  }
}

