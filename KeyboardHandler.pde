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

