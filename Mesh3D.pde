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