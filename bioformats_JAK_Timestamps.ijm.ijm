run("Bio-Formats Macro Extensions");


//////// Dialog box


Dialog.create("Timestamp Properties");
Dialog.addChoice("Time format:", newArray("hr:min:sec", "min:sec", "sec"));
Dialog.addChoice("Destination stack:", newArray("Original", "Z-projection","RGB", "Z-Projection + RGB"));
Dialog.addNumber("t = 0 timepoint", 1);
Dialog.show();

time_format = Dialog.getChoice;
destination = Dialog.getChoice;;
t_0 = Dialog.getNumber();



//////Get raw time values

id = getInfo("image.directory") + getInfo("image.filename");
Ext.setId(id);
Ext.getImageCount(imageCount);
deltaT = newArray(imageCount);
for (no = 0; no < imageCount; no++) {
  Ext.getPlaneTimingDeltaT(deltaT[no], no);
  }

//// Get time values for each timepoint

Ext.getSizeZ(z);
Ext.getSizeC(c);
Ext.getSizeT(t);


planes_per_time = z * c;

first_times = newArray(t);
first_planes = newArray(t);

temp = 0

for (i = 0; i < t; i++)
{
	first_planes[i] = temp;
	first_times[i] = deltaT[temp];
	temp = temp + planes_per_time; 
}
t_0value = first_times[t_0-1]
for (i = 0; i < t; i++)
{
	first_times[i] = first_times[i] - t_0value;
}

time_string = newArray(t)

if (time_format == "sec"){
	for (i = 0; i < t; i++){
	time_string[i] = toString(first_times[i]);
	}



} else if (time_format == "hr:min:sec"){
	
	for (i = 0; i < t; i++)
    
    
    
    {
	time = first_times[i];
	if (time < 0){
	sign = "-";
	}
	else {
		sign = " ";
	}

abstime = abs(time);

hrs_num = floor(abstime/3600);

hrs = toString(hrs_num);

if (hrs_num < 10) {
	hrs = "0"+hrs;
}

rem_min = abstime%3600;

min_num = floor(rem_min/60);

min = toString(min_num);

if (min_num < 10) {
	min = "0"+min;
}

rem_sec = rem_min%60;

sec_num = round(rem_sec);

sec = toString(sec_num);

if (sec_num < 10) {
	sec = "0" + sec;
}

temp_string = sign + hrs + ":" + min + ":" + sec;
time_string[i] = temp_string;
}
} else if (time_format == "min:sec"){
		
		
		for (i = 0; i < t; i++)
    {
    	time = first_times[i];
    	
if (time < 0){
	sign = "-";
	}
	else {
		sign = " ";
	}

abstime = abs(time);


min_num = floor(abstime/60);

min = toString(min_num);

if (min_num < 10) {
	min = "0"+min;
}

rem_sec = abstime%60;

sec_num = round(rem_sec);

sec = toString(sec_num);

if (sec_num < 10) {
	sec = "0" + sec;
}

temp_string = sign + min + ":" + sec;
time_string[i] = temp_string;

    }
	
}

if (destination == "Z-projection")
{
	run("Z Project...");
}

if (destination == "Z-projection + RGB")
{
	run("Z Project...");
	run("RGB Color", "frames keep");
}

if (destination == "RGB")
{
	run("RGB Color", "slices frames keep");

}


timepoint = 0;

for (i = 0; i < t; i++){
setSlice(i+1);
	s = time_string[i];
	run("Set Label...", "label=&s");
}

    