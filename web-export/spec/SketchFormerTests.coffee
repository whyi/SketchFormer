DEFAULT_LOAD_TIME_FOR_PROCESSINGJS = 500

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

