//Code that reads metadata from bioformats-compatible 
//files to adjust for movements in the stage that are recorded by the software
setBatchMode(true);
run("Bio-Formats Macro Extensions");


//////// Dialog box


Dialog.create("Shifting properties");
Dialog.addChoice("Positive X direction (image shift):", newArray("Left", "Right"));
Dialog.addChoice("Positive Y direction (image shift):", newArray("Up", "Down"));



Dialog.show();
xorient = Dialog.getChoice;
yorient = Dialog.getChoice;;

////

id = getInfo("image.directory") + getInfo("image.filename");
Ext.setId(id);

//get position of stage at each frame

Ext.getImageCount(imageCount);
xPos = newArray(imageCount);
yPos = newArray(imageCount);
for (no = 0; no < imageCount; no++) {
  Ext.getPlanePositionX(xPos[no], no);
  Ext.getPlanePositionY(yPos[no], no);
  }

//Adjust array to each timepoint
Ext.getSizeZ(z);
Ext.getSizeC(c);
Ext.getSizeT(t);

planes_per_time = z * c;

first_planes = newArray(t);
first_x = newArray(t);
first_y = newArray(t);

temp = 0

for (i = 0; i < t; i++)
{
	first_planes[i] = temp;
	first_x[i] = xPos[temp];
	first_y[i] = yPos[temp];
	temp = temp + planes_per_time; 
	
}

//normalize to first frame
imageCount = t;
xPosDelta = newArray(imageCount);
yPosDelta = newArray(imageCount);

for (no = 0; no < imageCount; no++) {
  xPosDelta[no] = first_x[no] - first_x[0] ;
  yPosDelta[no] = first_y[no] - first_y[0] ;
  }

//Convert movement to pixels and round to nearest pixel
Ext.getPixelsPhysicalSizeX(pix_size);


xDeltaPixels = newArray(imageCount);
yDeltaPixels = newArray(imageCount); 

for (no = 0; no < imageCount; no++) {
  xDeltaPixels[no] = round(xPosDelta[no]/pix_size) ;
  if (xorient == 'Right'){
  	xDeltaPixels[no] = -xDeltaPixels[no];
  }

  yDeltaPixels[no] = round(yPosDelta[no]/pix_size) ;
  if (yorient == 'Down'){
  	yDeltaPixels[no] = -yDeltaPixels[no];
  }
  }



//Get size of the original image

getDimensions(width, height, channels, slices, frames);

//get the extent of left and right and up and down
//movement of the stage in the movie

Array.getStatistics(xDeltaPixels, min, max, mean, stdDev);

left = 0 + min;
right = width + max;
xSize = right - left;
Array.getStatistics(yDeltaPixels, min, max, mean, stdDev);

top = 0 + min;
bottom = height + max;
ySize = bottom - top;

rename('Original_stack');

//make large black image of the same xy dimensions of the final
//stack to use as a concatenation base

newImage("base", "16-bit color-mode", xSize, ySize, 1, 1, 1);

selectWindow('Original_stack');
for (t = 1; t < frames + 1; t++) {
	x = toString(xDeltaPixels[t-1] - left);
	y = toString(yDeltaPixels[t-1] - top);
	for (c = 1; c < channels + 1; c++) {
		for (z = 1; z < slices + 1; z++) {
			selectWindow('Original_stack');
			Stack.setPosition(c, z, t);
			run("Duplicate...", "title=source");
			newImage("target", "16-bit color-mode", xSize, ySize, 1, 1, 1);
			run("Insert...", "source=[source] destination=[target] x=&x y=&y");
			run("Concatenate...", "  title=base open image1=[base] image2=[target] image3=[-- None --]");
			selectWindow('source');
			close();
		}
		
	}
}

selectWindow('base');
setSlice(1);
run("Delete Slice");
slices = toString(slices);
frames = toString(frames);
channels = toString(channels);
run("Stack to Hyperstack...", "order=xyzct channels=&channels slices=&slices frames=&frames display=Color");
rename("Stage-Corrected")
setBatchMode(false);