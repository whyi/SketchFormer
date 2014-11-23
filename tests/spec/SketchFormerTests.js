(function() {
  var DEFAULT_LOAD_TIME_FOR_PROCESSINGJS;

  DEFAULT_LOAD_TIME_FOR_PROCESSINGJS = 500;

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
    return describe("Mesh3D", function() {
      beforeEach(function() {
        this.pjs = Processing.getInstanceById(getProcessingSketchId());
        return this.mesh = this.pjs.getMesh();
      });
      return it("should be able to load mesh file", function() {
        return expect(this.mesh.loadMesh).toBeDefined();
      });
    });
  });

}).call(this);
