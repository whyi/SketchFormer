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
  /*
   The reason for hardcoding canvas size is because of the Processing.js bug where
   in dev-mode screen.width and screen.height cannot be resolved.
   In release (production) the hard-coded values can be replaced to screen.width and
   screen.height without any trouble. So this is dev-purpose only.
  */
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
