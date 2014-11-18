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
