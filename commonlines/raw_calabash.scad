module raw_calabash(r = 100, thick = 5, up = true, col = "SaddleBrown"){
    color(col)
    difference(){
        sphere(r = r);
        sphere(r = r-thick);
        translate([0,0,-r])
            cube(2*r+5, center = true);
    }
}

raw_calabash();