import java.util.Collections;
public class Mesh3D {
  private static final String MESH_API_URL = "http://www.whyi.net/bunny.json";
  private ArrayList vertices = null;
  private ArrayList corners = null;
  private ArrayList opposites = null;
  private ArrayList vertexNormals = null;
  private ArrayList triangleNormals = null;
  private boolean loaded = false;
  private PVector geometricCenter;
  private PVector minimumCoordinates;
  private PVector maximumCoordinates;
  
  private int numberOfVertices;
  private int numberOfCorners;
  private int numberOfTriangles;
  private final GeometricOperations geometricOperations;
  
  public Mesh3D(GeometricOperations geometricOperations) {
    this.geometricOperations = geometricOperations;
  }

  // for the O-Table
  private final class Triplet {
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

  public Mesh3D() {
    
  }

  private static void swap(ArrayList list, int a, int b) {
    Triplet tmp = (Triplet) list.get(a);
    list.set(a, list.get(b));
    list.set(b, tmp);
  }

  private static int partition(ArrayList list, int left, int right) {
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
  
  private static ArrayList naiveQuickSort(ArrayList list, int left, int right) {
    if (left < right) {
      final int pivot = partition(list, left, right);
      naiveQuickSort(list, left, pivot-1);
      naiveQuickSort(list, pivot+1, right);
    }
  }

  private static ArrayList naiveSort(ArrayList list) {
    naiveQuickSort(list, 0, list.size()-1);
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
    if (loaded == false)
      return;

    directionalLight(126, 126, 126, 0, 0, -1);
    ambientLight(255, 0, 0);

    lights();
    
    fill(0,255,0);
    
    stroke(3);

    for (int i = 0; i < numberOfTriangles; ++i) {
      PVector a = g(i*3);
      PVector normalA = vertexNormals.get(v(i*3)); 
      PVector b = g(i*3+1);
      PVector normalB = vertexNormals.get(v(i*3+1));
      PVector c = g(i*3+2);
      PVector normalC = vertexNormals.get(v(i*3+2));

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
    return vertices.get(corners.get(cornerIndex));
  }
  
  // shortcut to corner
  private Integer v(Integer cornerIndex) {
    return corners.get(cornerIndex);
  }
  
  // shortcut from vertex index to triangle index
  private int t(int cornerIndex) {
    return floor(cornerIndex/3);
  }
  
  // shortcut to the next corner
  private static final int n(int cornerIndex) {
    if (cornerIndex%3 == 2) {
      return cornerIndex-2;
    }
    return cornerIndex+1;
  }

  // shortcut to the previous corner
  private static final int p(int cornerIndex) {
    if (cornerIndex%3 == 0) {
      return cornerIndex+2;
    }
    return cornerIndex-1;
  }

  private static final boolean isBorder(int cornerIndex) {
    return (opposites.get(cornerIndex)==-1)? true:false;
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

    naiveSort(triples);
  
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
//    G.resize(nv * 4);
//    O.resize(nc * 4);
//    V.resize(nc * 4);
//    W.resize(nt * 12);
  }

  private void splitEdges() {
    // for each corner
    for (int corner=0; i<numberOfCorners; ++corner) {
      if (isBorder(corner)) {
        vertices.add(GeometricOprations.midpt(g(n(i)), g(p(i))));
        W[i] = vertices.size()-1;
      }
      else {
        // if this corner is the first to see the edge
        if (i < o(i)) {
          vertices.add(GeometricOprations.midpt(g(n(i)), g(p(i))));
          W[o(i)] = vertices.size()-1;
          W[i] = vertices.size()-1;
        }
      }
    }
  }  
}
