$fs = 0.5;
$fa = 2;

use <Metric/M3.scad>;
use <Metric/M2.scad>;
use <servo.scad>;

m3r=1.65;
module m3(l=16,nuts=false){
	if(nuts){
		translate([0,0,1]) NutM3(inset=0);
	}else{
		translate([0,0,l]) BoltM3(l=l,inset=0);
	}
}

sunit=8;
thickness=4;
len=50;
shaftLen=60;
module screws(nuts=false){
	translate([0,0,-1]) group(){
		translate([sunit/2,sunit/2,]) m3(nuts=nuts);
		translate([sunit/2,len-sunit*1.3-thickness,0]) m3(nuts=nuts);
		translate([sunit/2,len-sunit/2,0]) m3(nuts=nuts);
	}

	translate([sunit*2,0,-1]) group(){
		translate([sunit/2,sunit/2,0]) m3(nuts=nuts);
		translate([sunit/2,len-sunit/2,0]) m3(nuts=nuts);
	}
	
}

module spacers(len=50,thickness=4,sunit=8){
	difference(){
		union(){
			cube([sunit,len-sunit*1.3,thickness]);
			translate([sunit*2,0,0]) cube([sunit,len,thickness]);
			translate([sunit*3-thickness/2,len+1,thickness/2]) cube([2,thickness,2],center=true);
		}	
		screws();
		// Grooves Sharp
		translate([sunit,0,0]) group(){ 
			translate([0.5,-1,0.5]) rotate([45,0,90])cube([len+10,2,2]);
			translate([-0.5+sunit,-1,0.5]) rotate([45,0,90])cube([len+10,2,2]);
		}
		// Grooves round
		//translate([sunit*2,len/2-1,thickness/2]) rotate([-90,0,0]) cylinder(r=1.5,h=len+3,center=true);
		//translate([sunit,len/2-1,thickness/2]) rotate([-90,0,0]) cylinder(r=1.5,h=len+3,center=true);
	}

}

module sidePiece(nuts=false,top=false){
	difference(){
		cube([sunit*3,len,thickness]);
		screws();
		if(nuts){
			if(top){
				screws(nuts=true);
			}else{
				translate([0,0,thickness-thickness/2]) screws(nuts=true);
			}
		}
		translate([sunit+sunit/2,sunit,thickness/2]) hull(){
			cylinder(r=sunit/2-1,h=thickness+2,center=true);
			translate([0,len-sunit*2-sunit/2,0]) cylinder(r=sunit/2-1,h=thickness+2,center=true);
		}
		translate([sunit+1,-1,-1]) {
			cube([2,4,thickness +2 ]);
			translate([sunit-3,0,0]) cube([2,4,thickness +2 ]);
		}
	}
}
module shaft(){
	translate([sunit,sunit,0]) union(){
		difference(){
			translate([0,0,0]) cube([sunit,shaftLen,thickness]);
			translate([sunit/2,sunit/2+2,2]) cylinder(r=sunit/2-2,h=thickness+2,center=true);
			translate([sunit/2,sunit/2+2+sunit*1.5,2]) cylinder(r=sunit/2-2,h=thickness+2,center=true);
			translate([sunit/2,sunit/2+2+sunit*3,2]) cylinder(r=sunit/2-2,h=thickness+2,center=true);
			translate([-1,2,0.85]) rotate([45,0,0])cube([sunit+2,1.5,1.5]);
			translate([-0.5,-1,0.5]) rotate([45,0,90])cube([len+10,2,2]);
			translate([0.5+sunit,-1,0.5]) rotate([45,0,90])cube([len+10,2,2]);
		}
		//sensormount
		translate([-6,shaftLen,0]) difference(){
			cube([20,sunit+2,thickness*2]);
			translate([0,thickness+1,0]){ 
				translate([thickness+1,0,0]){
					translate([0,0,15]) BoltM2(l=22,inset=0);
					NutM2(inset=0);
					translate([9.46,0,0]){
						translate([0,0,15]) BoltM2(l=22,inset=0);
						NutM2(inset=0);
					}
				}
			}
		}

	}
}
module motorMount(){
	difference(){
		union(){ 
			translate([-15, -20.7,0]) difference(){
				cube([15,20.7,thickness]);
				translate([-12,16,-1])
					rotate([0,0,-45]) cube([15,40,thickness+2]);

			}
			translate([-15,-len,0]) cube([15,6,thickness]);
		}
		translate([-15+6,-22+4,thickness-1.4]) {
			NutM2(inset=0);
			translate([0,0,3])BoltM2(inset=0);
		}			
		translate([-15+6,-22+4-28.45,thickness-1.4]) {
			NutM2(inset=0);
			translate([0,0,3]) BoltM2(inset=0);
		}			
	}
}

module hotendMount(){
	difference(){ 
		union(){
			cube([35,10,5]);
			translate([20,0,0]) rotate([0,0,39]) cube([20,9.5,5]);
			translate([29,10,0]) cube([10,10,5]);
		}
		union() translate([5,5,0]) {
			translate([0,0,thickness+1]) BoltM3(inset=0);
			translate([24,0,thickness+1]) BoltM3(inset=0);
		}	
	}
}
// Base Piece
!union(){
	translate([0,0,thickness]) spacers();
	sidePiece();
	translate([0,len,0]) motorMount();
	// Change this  part for your printer,
	// Currently configured to fit a Geeetech Prusa I3 Pro B with stock MK8 extuder.
	translate([63,len+10,0]) rotate([0,0,180]) hotendMount();
}
translate([-15.30,46-16.8,-19.0]) rotate([0,0,-90]) servoSG90();
// Cover
//translate([0,0,sunit])
color("blue") translate([40,0,0]) sidePiece(nuts=true);

// Shaft
color("purple") translate([0,0,thickness])	shaft();

// pulley
translate([4,len-4,thickness/2 + thickness]) rotate_extrude() difference(){
	translate([1.88,-thickness/2,0]) square([thickness-2,thickness]);
	translate([thickness+0.1,0,0]) circle(thickness/3,center=true);
};