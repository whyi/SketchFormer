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

  private void splitTriangles() {
    // $$$ FIXME: maybe those indices in the for loop can be replaced with the numberOfTriangles
    //            instead of corners, given that I'm doing corner+=3

    for (int corner = 0; corner < numberOfCorners; corner+=3) {

      final int previousCorner = temporaryCorners[p(corner)];
      final int nextCorner = temporaryCorners[n(corner)];

      int cornerIndex = 3*numberOfTriangles+corner;
      corners.set(cornerIndex, v(corner));
      corners.set(n(cornerIndex), temporaryCorners[previousCorner]);
      corners.set(p(cornerIndex), temporaryCorners[nextCorner]);
      
      cornerIndex = 6*numberOfTriangles+corner;
      corners.set(cornerIndex, v(corner));
      corners.set(n(cornerIndex), temporaryCorners[previousCorner]);
      corners.set(p(cornerIndex), temporaryCorners[nextCorner]);

      cornerIndex = 9*numberOfTriangles+corner;
      corners.set(cornerIndex, v(corner));
      corners.set(n(cornerIndex), temporaryCorners[previousCorner]);
      corners.set(p(cornerIndex), temporaryCorners[nextCorner]);

    }
    numberOfTriangles = 4*numberOfTriangles;
    numberOfCorners = 3*numberOfTriangles;
  }
}

