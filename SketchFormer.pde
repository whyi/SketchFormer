float xDragged = 0;
float yDragged = 0;
bool dragged = false;
Point3D dragCoordinate;
Camera3D myCamera = new Camera3D(0,0,0,100);
Mesh3D mesh = new Mesh3D();

void setup() {
  size(1500, 600, P3D); 
  noFill();
  mesh.loadMesh();
  myCamera.viewAt(mesh.geometricCenter);
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
