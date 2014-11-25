float xDragged = 0;
float yDragged = 0;
Boolean dragged = false;
PVector dragCoordinate;
public Camera3D myCamera = new Camera3D(0,0,-400,100);
public GeometricOperations geometricOperations = new GeometricOperations();
public OTableHelper myOTableHelper = new OTableHelper();
public Mesh3D mesh = new Mesh3D(geometricOperations, myOTableHelper);

public Mesh3D getMesh() {
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
