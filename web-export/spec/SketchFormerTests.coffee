DEFAULT_LOAD_TIME_FOR_PROCESSINGJS = 100

prepareForProcessingJsTesting: -> true

describe "SketchFormer", ->
  beforeEach (prepareForProcessingJsTesting) ->
    setTimeout( ()->
      prepareForProcessingJsTesting()
    , DEFAULT_LOAD_TIME_FOR_PROCESSINGJS)

  describe "Mesh3D", ->
    beforeEach ->
      @pjs = Processing.getInstanceById(getProcessingSketchId())
      @mesh = @pjs.getMesh()

    it "should be able to load mesh file", ->
      expect(@mesh.loadMesh).toBeDefined()

    it "should be able to compute width", ->
      expect(@mesh.width).toBeDefined()

    it "should be able to compute height", ->
      expect(@mesh.height).toBeDefined()

    describe "given width and height are 100 respectively", ->
      beforeEach ->
        spyOn(@mesh, "width").and.returnValue(100)
        spyOn(@mesh, "height").and.returnValue(100)

      describe "when diag()", ->
        beforeEach ->
          @returnedDiag = @mesh.diag()

        it "should return 141.4213562373095", ->
          expect(@returnedDiag).toBe(141.4213562373095)

    describe "when loadMesh()", ->
      beforeEach ->
        spyOn(@mesh, "computeBoundingBox")
        spyOn(@mesh, "computeNormals")
        spyOn(@mesh, "computeGeometricCenter")
        spyOn(@mesh, "buildOTable")
        @mesh.loadMesh()

      it "should read numberOfVertices", ->
        expect(@mesh.numberOfVertices).toBe(102)

      it "should read numberOfTriangles", ->
        expect(@mesh.numberOfTriangles).toBe(200)

      it "should read numberOfCorners", ->
        expect(@mesh.numberOfCorners).toBe(600)

      it "should compute bounding box", ->
        expect(@mesh.computeBoundingBox).toHaveBeenCalled()

      it "should compute GeometricCenter", ->
        expect(@mesh.computeGeometricCenter).toHaveBeenCalled()

      it "should compute normals", ->
        expect(@mesh.computeNormals).toHaveBeenCalled()

      it "should build OTable", ->
        expect(@mesh.buildOTable).toHaveBeenCalled()

      it "should mark the mesh as loaded", ->
        expect(@mesh.loaded).toBe(true)

  describe "GeometricOperations", ->
    beforeEach ->
      @pjs = Processing.getInstanceById(getProcessingSketchId())
      @geometricOpertaions = @pjs.getGeometricOperations()

    describe "midPt", ->
      it "should return mid point of two PVectors", ->
        pointA = {x:10,y:10,z:10}
        pointB = {x:20,y:20,z:20}
        midPoint = {x:15,y:15,z:15}
        expect(@geometricOpertaions.midPt(pointA, pointB)).toEqual(midPoint)

    describe "vector", ->
      it "should compute and return a vector of two points", ->
        pointA = {x:10,y:10,z:10}
        pointB = {x:20,y:20,z:20}
        vectorAB = {x:10,y:10,z:10}
        expect(@geometricOpertaions.vector(pointA, pointB)).toEqual(vectorAB)

    describe "triNormal", ->
      it "should compute and return a normalized normal vector", ->
        pointA = {x:0,y:0,z:0}
        pointB = {x:10,y:0,z:0}
        pointC = {x:10,y:10,z:0}
        expectedNormal = {x:10,y:10,z:10}
        expect(@geometricOpertaions.triNormal(pointA, pointB, pointC)).toEqual(expectedNormal)
