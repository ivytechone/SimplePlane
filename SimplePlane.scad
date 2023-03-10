// SimplePlane
// ----------------------

$fn=64;

function inchToMm(x) = x*25.4;

// Parameters
length=inchToMm(24);
width=inchToMm(1.6);  //(inside width)
height=40;
wallWidth=1.5;

noseLength=inchToMm(10);

batteryWidth=19.5;
batteryHeight=34.5;
batteryLength=69;
batteryPos=inchToMm(4);

servoWidth=12;
servoLength=23.75;
servoHeight=18;
servoPos=inchToMm(8);

wingLeadingEdge=inchToMm(6);
wingCutoutHeight=5;

motorMountLength=3;
motorMountHoleSize=2.75/2;
motorMountHolePatternRadius=8;

thrustAngle=3;

outerWidth = width + (2 * wallWidth);
outerHeight = height + (2 * wallWidth);

batteryHolderOuterWidth=batteryWidth+(2*wallWidth);
batteryHolderOffset=(outerWidth - batteryHolderOuterWidth) / 2;
    
tailWidth=14;
tailLength=inchToMm(14);
    
jointLength=20;
    
mode=0;

if (mode==0) Plane(); // Whole Plane
if (mode==1) NoseSegment(0,80, true); // Nose Section
if (mode==2) NoseSegment(80,120, false); // Battery Section
if (mode==3) NoseSegment(200,120, false);    
if (mode==4) NoseSegment(320,150, true);
if (mode==5) NoseSegment(470,150, true);
if (mode==6) FrontWingClip();

module BackWingClip()
{
    difference()
    {
        cube([12,width-5, 2],center=true);
        cylinder(h=10, r=1,center=true);
    }
}

module FrontWingClip()
{
    h1=9;
    h2=4;
    d2=tan(72)*h2;
    echo(d2);
    t=2;
    tabThickness=8.9;
    
    difference()
    {
        union()
        {
            linear_extrude(width)
            polygon([[-15,0],
                 [0,h1+t],
                 [d2,h1+h2],
                 [d2,h1+h2-t],
                 [t,h1],
                 [t,0],
                 [0,0]]
            );
            
            linear_extrude(tabThickness)
            polygon([
                [-15,0],
                [t,0],
                [t+10, -15],
                [-25, -15]
            ]);
            
            translate([0,0,width-tabThickness])
            linear_extrude(tabThickness)
            polygon([
                [-15,0],
                [t,0],
                [t+10, -15],
                [-25, -15]
            ]);
        }
        translate([0,0,width/2])
        rotate([0,0,15])
        cube([40, 9, batteryWidth], center=true);
    }
}

module NoseSegment(start, end, first)
{
intersection()
{
        translate([-start,0,0]) Plane();
        cube([end,1000,1000]);
}

    if (!first)
    {
        translate([-(jointLength/2),wallWidth,wallWidth])
        joint();
    }
}

module joint()
{
    jointThickness=1;
    jointMargin=.2;
    jointHeight=height+wallWidth-wingCutoutHeight;
    difference()
    {
        cube([jointLength, width, jointHeight]);
        cube([jointLength/2,jointMargin,jointHeight]);
        cube([jointLength/2,width,jointMargin]);
        translate([0,width-jointMargin,0]) cube([jointLength/2,jointMargin,jointHeight]);
        translate([0,jointThickness,jointThickness]) 
            cube([jointLength, width-(2*jointThickness), jointHeight]);
    }
}

module WingHolder()
{
    //translate([10, -8, 60])
    
    difference()
    {
        cube([5, 16+outerWidth, 8]);
        translate([0,8,0]) cube([6, outerWidth, 4]);
    }
}

module Plane()
{
    union()
    {
        NoseModule();
        translate([noseLength,0,0])Tail();
    }
}

module NoseModule()
{
    landingGearDiameter=3;
    
    union()
    {
    difference()
    {
        cube([noseLength, outerWidth, outerHeight]);
        
        translate([0, wallWidth, wallWidth]) cube([noseLength, width, height+wallWidth]);
        
        translate([wingLeadingEdge,0,outerHeight-wingCutoutHeight]) cube([noseLength, outerWidth, wingCutoutHeight]);
        
        NoseCutout();
        
        // slot for landing gear
        linear_extrude(50)
        polygon([[batteryPos-landingGearDiameter,12],
                 [batteryPos-landingGearDiameter,outerWidth-12],
                 [batteryPos,outerWidth-12],
                 [batteryPos,12]]);
       
    }

    // front support for landing gear
    translate([batteryPos-3,0,0])
    rotate([0,-90,0])
    linear_extrude(9)    
    polygon([[0, 12],
             [10, 12],
             [20, 0],
             [height, 0],
             [height, outerWidth],
             [20, outerWidth],
             [10, outerWidth-12],
             [0, outerWidth-12]]);
 
    
    // connect front support to battery holder
    translate([batteryPos-landingGearDiameter,30,0])
    rotate([90,0,0])
    linear_extrude(20)
    polygon([[0,20],
             [landingGearDiameter,30],
             [landingGearDiameter,height],
             [0, height],
             [0,20]]);
    
    translate([batteryPos,batteryHolderOffset,wallWidth]) BatteryHolder();
    
    translate([0,0,0]) Nose();
    }   
}

module Nose()
{
    rotate([0,0,-thrustAngle])
    difference()
    {
    cube([motorMountLength, outerWidth, outerHeight]);
    translate([0,outerWidth/2,outerHeight/2]) MotorMount();
    }
}

module NoseCutout()
{
    rotate([0,0,-thrustAngle])
    translate([-10,0,0])
    cube([10, outerWidth+10, outerHeight]);
}

module MotorMount()
{
    offset=sqrt((motorMountHolePatternRadius*motorMountHolePatternRadius)/2);
    
    union()
    {
        translate([0,offset,offset])
        rotate([0,90,0])
        cylinder(motorMountLength, motorMountHoleSize, motorMountHoleSize);
        
        translate([0,offset,-offset])
        rotate([0,90,0])
        cylinder(motorMountLength, motorMountHoleSize, motorMountHoleSize);
        
        translate([0,-offset,-offset])
        rotate([0,90,0])
        cylinder(motorMountLength, motorMountHoleSize, motorMountHoleSize);
        
        translate([0,-offset,offset])
        rotate([0,90,0])
        cylinder(motorMountLength, motorMountHoleSize, motorMountHoleSize);
        
        translate([0,-5,9])
        cube([motorMountLength,10,4.25]);
    }
}

module BatteryHolder()
{
    union()
    {
        difference()
        {
            cube([batteryLength+wallWidth, batteryHolderOuterWidth, batteryHeight]);
            translate([0,wallWidth,0])
            cube([batteryLength+wallWidth, batteryWidth, batteryHeight]);
        }
        
        cube([wallWidth+3, batteryHolderOuterWidth, batteryHeight]);
    }
}

module Tail()
{
    offset = (outerWidth-tailWidth) / 2;
        
    hStabWidth=4;
    hStabLength=85;
    hStabOffset=(outerWidth-hStabWidth) / 2;
    tailLength=length-noseLength;
    
    difference()
    {
        linear_extrude(outerHeight-wingCutoutHeight)
        polygon([[0,0],[0, outerWidth],[tailLength, offset+tailWidth],[tailLength,offset]]);

        vStabCutHeight=outerHeight-wingCutoutHeight-20;
        
        // cut along bottom
        translate([0,50,0])
        rotate([90,0,0])
        linear_extrude(100)
        polygon([[0,0],
            [tailLength,0],
            [tailLength,20]]);

        //cutout for horizontal stabalizer
        translate([0,50,0])
        rotate([90,0,0])
        linear_extrude(100)
        polygon([[tailLength-hStabLength,0],
                [tailLength-hStabLength,vStabCutHeight],
                [tailLength,vStabCutHeight],
                [tailLength,0]]);
        
        //cutout for vertical stabalizer
        linear_extrude(115)
        polygon([[tailLength, hStabOffset],
             [tailLength-hStabLength, hStabOffset],
             [tailLength-hStabLength, hStabOffset+hStabWidth],
             [tailLength, hStabOffset+hStabWidth]]);
        
        // hollow part
        translate([-1,width/2, width/2])
        rotate([0,88.5,0])
        cylinder(tailLength-hStabLength-5, 16, 8); 
    } 
}
