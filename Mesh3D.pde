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
