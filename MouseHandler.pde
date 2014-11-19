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

