(function() {
  var DEFAULT_LOAD_TIME_FOR_PROCESSINGJS;

  DEFAULT_LOAD_TIME_FOR_PROCESSINGJS = 100;

  ({
    prepareForProcessingJsTesting: function() {
      return true;
    }
  });

  describe("SketchFormer", function() {
    beforeEach(function(prepareForProcessingJsTesting) {
      return setTimeout(function() {
        return prepareForProcessingJsTesting();
      }, DEFAULT_LOAD_TIME_FOR_PROCESSINGJS);
    });
    describe("Mesh3D", function() {
      beforeEach(function() {
        this.pjs = Processing.getInstanceById(getProcessingSketchId());
        return this.mesh = this.pjs.getMesh();
      });
      it("should be able to load mesh file", function() {
        return expect(this.mesh.loadMesh).toBeDefined();
      });
      it("should be able to compute width", function() {
        return expect(this.mesh.width).toBeDefined();
      });
      it("should be able to compute height", function() {
        return expect(this.mesh.height).toBeDefined();
      });
      describe("given width and height are 100 respectively", function() {
        beforeEach(function() {
          spyOn(this.mesh, "width").and.returnValue(100);
          return spyOn(this.mesh, "height").and.returnValue(100);
        });
        return describe("when diag()", function() {
          beforeEach(function() {
            return this.returnedDiag = this.mesh.diag();
          });
          return it("should return 141.4213562373095", function() {
            return expect(this.returnedDiag).toBe(141.4213562373095);
          });
        });
      });
      return describe("when loadMesh()", function() {
        beforeEach(function() {
          spyOn(this.mesh, "computeBoundingBox");
          spyOn(this.mesh, "computeNormals");
          spyOn(this.mesh, "computeGeometricCenter");
          spyOn(this.mesh, "buildOTable");
          return this.mesh.loadMesh();
        });
        it("should read numberOfVertices", function() {
          return expect(this.mesh.numberOfVertices).toBe(102);
        });
        it("should read numberOfTriangles", function() {
          return expect(this.mesh.numberOfTriangles).toBe(200);
        });
        it("should read numberOfCorners", function() {
          return expect(this.mesh.numberOfCorners).toBe(600);
        });
        it("should compute bounding box", function() {
          return expect(this.mesh.computeBoundingBox).toHaveBeenCalled();
        });
        it("should compute GeometricCenter", function() {
          return expect(this.mesh.computeGeometricCenter).toHaveBeenCalled();
        });
        it("should compute normals", function() {
          return expect(this.mesh.computeNormals).toHaveBeenCalled();
        });
        it("should build OTable", function() {
          return expect(this.mesh.buildOTable).toHaveBeenCalled();
        });
        return it("should mark the mesh as loaded", function() {
          return expect(this.mesh.loaded).toBe(true);
        });
      });
    });
    return describe("GeometricOperations", function() {
      beforeEach(function() {
        this.pjs = Processing.getInstanceById(getProcessingSketchId());
        return this.geometricOpertaions = this.pjs.getGeometricOperations();
      });
      describe("midPt", function() {
        return it("should return mid point of two PVectors", function() {
          var midPoint, pointA, pointB;
          pointA = {
            x: 10,
            y: 10,
            z: 10
          };
          pointB = {
            x: 20,
            y: 20,
            z: 20
          };
          midPoint = {
            x: 15,
            y: 15,
            z: 15
          };
          return expect(this.geometricOpertaions.midPt(pointA, pointB)).toEqual(midPoint);
        });
      });
      describe("vector", function() {
        return it("should compute and return a vector of two points", function() {
          var pointA, pointB, vectorAB;
          pointA = {
            x: 10,
            y: 10,
            z: 10
          };
          pointB = {
            x: 20,
            y: 20,
            z: 20
          };
          vectorAB = {
            x: 10,
            y: 10,
            z: 10
          };
          return expect(this.geometricOpertaions.vector(pointA, pointB)).toEqual(vectorAB);
        });
      });
      return describe("triNormal", function() {
        return it("should compute and return a normalized normal vector", function() {
          var expectedNormal, pointA, pointB, pointC;
          pointA = {
            x: 0,
            y: 0,
            z: 0
          };
          pointB = {
            x: 10,
            y: 0,
            z: 0
          };
          pointC = {
            x: 10,
            y: 10,
            z: 0
          };
          expectedNormal = {
            x: 0,
            y: 0,
            z: 1
          };
          return expect(this.geometricOpertaions.triNormal(pointA, pointB, pointC)).toEqual(expectedNormal);
        });
      });
    });
  });

}).call(this);
