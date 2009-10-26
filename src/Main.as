package 
{
  import flash.utils.*;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMat;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
  import org.papervision3d.objects.parsers.Collada;
	
	/**
	 * ...
	 * @author Mikko Haapoja
	 */
	public class Main extends Sprite 
	{
		/*
		 * camera_para.dat is a Binary file created by --PROGRAM NAME HERE--
		 * Basically what it does is give information for FlarToolkit to
		 * correct distortion and stuff like that, that your camera does.
		 * It will also contain a Projection Matrix
		 */
		[Embed(source="../lib/camera_para.dat", mimeType="application/octet-stream")]
		private var CameraParameters:Class;
		
		/*
		 * mikko.pat is a Pattern I've created using the Air App provided by
		 * Saqoosha. There are 4 16x48 matrices. One 16x48 matrix represents
		 * the colours in your marker from one direction. Basically your marker
		 * is reduced to 16 pixels by Saqoosha's air app. So it is
		 * 16 by (16 x 3 colours red, green, blue)= 16 by 48 matrix
		 */
		[Embed(source="../lib/flar-simple.pat", mimeType="application/octet-stream")]
		private var MarkerPattern:Class;
		
		private var cameraParameters:FLARParam;
		private var markerPattern:FLARCode;
		private var raster:FLARRgbRaster_BitmapData;
		private var detector:FLARSingleMarkerDetector;
		
		private var cam:Camera;
		private var vid:Video;
		private var capture:BitmapData;
		
		private var cam3D:FLARCamera3D;
		private var scene3D:Scene3D;
		private var viewPort:Viewport3D;
		private var mainContainer:FLARBaseNode;
		private var renderer:LazyRenderEngine;
		private var planeMat:FlatShadeMaterial;
		private var numShot:uint = 0;
		
		private var trans:FLARTransMatResult;
		private var prevSet:Boolean = false;
		private var prevZ:Number = 0;
		
		public function Main():void 
		{
			/*
			 * cameraParameters will hold our parameters from the camera noted above.
			 * Flar will use the camera parameters to make your 3d stuff
			 * look right
			 */
			cameraParameters = new FLARParam();
			cameraParameters.loadARParam(new CameraParameters() as ByteArray);
			
			/*
			 * markerPattern will hold the data from our pattern file for Flar
			 * to use to look for our Marker
			 */
			markerPattern = new FLARCode(16, 16);
			markerPattern.loadARPatt(new MarkerPattern());
			
			//Get our webcam going
			cam = Camera.getCamera();
			//Set the webcam to run as 640x480
			//at 30 frames per second
			cam.setMode(640, 480, 30);
			
			//Create a new video object to show our webcam
			vid = new Video();
			vid.width = 640;
			vid.height = 480;
			//vid.x = stage.stageWidth/2-vid.width/2;
			//vid.y = stage.stageHeight/2-vid.height/2;
			vid.attachCamera(cam);
			addChild(vid);
			
			/*
			 * capture will hold BitmapData of what is shown on the 
			 * webcam FlarToolkit will use this bitmapdata to look
			 * for our mark pattern
			 * 
			 * we will need to redraw vid to capture every frame
			 */
			capture = new BitmapData(vid.width, vid.height, false, 0x0);
			capture.draw(vid);
			
			/*
			 * raster will hold our BitmapData for Flar to use
			 */
			raster = new FLARRgbRaster_BitmapData(capture);
			detector = new FLARSingleMarkerDetector(cameraParameters, markerPattern, 80);
			
			/*
			 * cam3d is a Papervision Cam3D
			 * and will be our 3d camera that is setup
			 * from our camera data file imported above
			 */
			cam3D = new FLARCamera3D(cameraParameters);
			
			//Papervision scence
			scene3D = new Scene3D();
			
			/*
			 * This is our mainContainer what will happen
			 * is that Flar will give us a transformation
			 * matrix based on the marker and we can use
			 * that transformation matrix to rotate the
			 * mainContainer
			 */
			mainContainer = new FLARBaseNode();
			scene3D.addChild(mainContainer);
			
			/*
			 * This is our Papervision viewport
			 * This is a gotcha... I'm not sure why the viewPort needs
			 * to be the same size as the video but then scaled up twice
			 * even still then it's a bit offset. I didn't feel like doing
			 * more offsetting because I don't like that kind of stuff
			 * 
			 * Maybe we can figure this one out together
			 */
			viewPort = new Viewport3D(vid.width, vid.height);
			viewPort.scaleX = viewPort.scaleY = 2;
			addChild(viewPort);
			
			//Our papervision renderer
			renderer = new LazyRenderEngine(scene3D, cam3D, viewPort);
			
			//Papervision light
			var light:PointLight3D = new PointLight3D();
			light.x = 1000;
			light.y = 1000;
			light.z = -1000;
			
			var cubeMaterialList:MaterialsList = new MaterialsList( { all: new FlatShadeMaterial(light, 0x0099FF, 0x0066AA) } );
			
			var cube:Cube = new Cube(cubeMaterialList,
									 30,
									 30,
									 30);
			
			cube.z += 15;

      var cow:Collada = new Collada("http://www.tartiflop.com/pv3d/FirstSteps/collada/cow.dae", null, 0.5);

			//mainContainer.addChild(cube);
      mainContainer.addChild(cow);
      
      mainContainer.yaw(45);
			cow.z += 5;
      cow.pitch(90);

			//Material for our plane
			var wMat:WireframeMaterial = new WireframeMaterial(0x0033FF, 1, 1);
			wMat.doubleSided = true;
		//	var plane:Plane = new Plane(wMat, 80, 80);
		//	mainContainer.addChild(plane);
			/*
			 * This is a Transformation matrix which Flar will
			 * fill and then we will use this to rotate mainContainer
			 */
			trans = new FLARTransMatResult();
			
			//Main loop where all the magic happens
			this.addEventListener(Event.ENTER_FRAME, mainEnter);
		}
		
		private function mainEnter(e:Event):void 
		{
      //trace("cube", getQualifiedSuperclassName(this.mainContainer));
			/*
			* Draw the current video screen to our capture
			* Flar will use this to figure out where our marker is
			*/
			capture.draw(vid);
		  mainContainer.yaw(3);	
      //trace("yaw", mainContainer.yaw);
			/*
			 * detector.detectMarkerLite(raster, 80) <-if marker found
			 * detector.getConfidence() <-how confident flar is in its find
			 */
			if (detector.detectMarkerLite(raster, 80) && detector.getConfidence() > 0.5)
			{
        mainContainer.x += 4;
				//Get the transfomration matrix for the current marker position
				detector.getTransformMatrix(trans);
				
				//Translates and rotates the mainContainer so it looks right
				mainContainer.setTransformMatrix(trans);
				
				//Render the papervision scene
				renderer.render();
			}
		}
	}
	
}
