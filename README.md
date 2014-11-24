# SketchFormer - Revolutionary Mesh Deformation Project implemented on web.

## Introduction
This is an implementation of SketchFormer (http://youtu.be/74rULDZlPl4) using processingjs.org

## How to compile/build/run
 * Grab the latest Processing from http://www.processing.org/
 * ```git clone https://github.com/whyi/SketchFormer.git```
 * Open SketchFormer.pde from Processing, it will load all the other files together.
 * Ctrl+R or [Sketch]-[Run In Browser] will bring this up!

## Unit testing
 * SketchFormer uses Jasmine and Coffeescript as the framework for unittest.
 * Have the SketchFormer running via Processing, as described in the previous section.
 * Open a shell, execute runTests.sh
 * Now, navigate to http://127.0.0.1:RUNNING_PROCESISNG_PORT/SpecRunner.html within the browser where the RUNNING_PROCESSING_PORT is the port number of a running Processing instance. This will be provided when you run the SketchFormer as described in the previous section.

## See it in action
The following page should give you the real-time demo in any webbrowser!
* http://www.whyi.net/geometry/SketchFormer/

## Contribution welcomed
This is a very ambitious project to provide an eco-system for the next generation Computational Geometry.
I have some pieces of code that I am still trying to bring-in, but it is very limited in certain geometric operations.
If you have some geometric pieces of code, bring it on! Your help would be appreciated.
