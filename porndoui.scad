//n = nombre de triangles équilatéraux avec quarts de cercle
n=3;
echo(str("n=",n));

//les triangles équilatéraux sont indexés k :
// 0 pour la grande croix
//1 à n-1 pour les triangles avec quart de cercle
//n pour le triangle plein

//r0 = rayon de la sphère initiale
r0=100;
r0plus = 1.1*r0;
echo(str("r0=",r0));

//ep = épaisseur de la sphère
ep = r0/50;
echo(str("ep=",ep));

//$fs = min fragment size for a circle
$fs=1;
echo(str("$fs=",$fs));

//$fa = min angle fragment size for a circle
$fa=5;
//$fa=2; //1min 36s

//r1 = rapport espacement/largeur trait des triangles équilatéraux
r1=3;
echo(str("r1=",r1));

//r2 = rapport largeur trait grande croix / largeur trait triangles équilatéraux
r2=1.5;
echo(str("r2=",r2));

//r3 = rapport largeur trait petit carré au fond / largeur trait triangles équilatéraux
r3=1;
echo(str("r3=",r3));

//r4 = rapport largeur "trait" triangle équilatéral plein central / largeur trait triangle équilatéral
r4=3;
echo(str("r4=",r4));

//r5 = rapport rayon 1/4 cercle placé à l'angle des triangles équilatéraux / largeur trait triangle équilatéral
r5=2;
echo(str("r5=",r5));

//ep1= épaisseur d'un demi-cube intersectant
sq3 = sqrt(3);
ep1 = r0/sq3/ (n+(n+1)*r1+r2+r4);
echo(str("ep1=",ep1));

//épaisseur d'un demi-cube en fonction de k
function dcub_ep(k) = (k==0) ? (ep1*r2) :  (k==n+1) ? (ep1*r4) : ep1  ;

//position d'un demi-cube intersectant en fonction de k
function dcub_pos(k) = (k==0) ? 0 : ( ep1* (r2 + r1 + (k-1)*(1+r1)) ) ;

for (k = [0:1:n+1])
{
    echo(str("k=0 : dcub_ep = ", dcub_ep(k), " , dcub_pos = ", dcub_pos(k)));
}

//rayon d'un 1/4 cylindre servant à faire les coins
qcyl_ray = r5 * ep1;

//calculer l'angle depuis l'axe a (1 pour x, 2 pour y, 3 pour z), pour atteindre le coin k 
//cet angle est à appliquer 2 fois (selon les deux autres axes)
function ang1(k) = asin(dcub_pos(k)/r0);

//fonction caractéristique des axes à utiliser pour la rotation
//retourne 1 si l'axe test est concerné pour la rotation qui va au coin a
function axis(a, test) = (test==a) ? 0:1;

//axe du coin à atteindre (a)
function corner_axis(a) = [for (test = [1:1:3]) (a==test) ? 1:0];

//coordonnées du coin à atteindre (k, a)
function corner(k,a)=
    [
        let(d = dcub_pos(k)+dcub_ep(k))
        for (test = [1:1:3])
            (a==test) ? sqrt( pow(r0,2) - 2*pow(d,2)) : d 
    ];
    
//axe de rotation pour atteindre le coin
function corner_rotaxis(k,a) = cross(corner_axis(a),corner(k,a));
        
//angle de rotation pour atteindre le coin
function corner_rotang(k,a) = acos(corner_axis(a)*corner(k,a)/norm(corner_axis(a))/norm(corner(k,a)));

//rotation d'un 1/4 cylindre pour prépositionner sur l'axe concerné en fonction de a (retourne une liste d'angles)
function qcyl_prepos(a) =
        (a==1) ? [90, 0, 90] : (a==2) ? [0,-90,-90] : [0,0,0] ;
        
//dernière encoche (épaisseur r3*ep1)
//translation après prépositionnement
encoch_pos = (r2 + r1 / 2)* ep1 ;
        
function encoch_trans() = [encoch_pos, encoch_pos, 0];


//Modules
//créer la 1/8 sphère initiale
module sphi()
{   
    difference()
        {
            difference()
            {
                sphere(r0);
                sphere(r0-ep);
            }
            
            difference()
            {
                cube(2*r0plus, center=true);
                cube(r0plus);
            }
        }
    }
    
//créer 1/2 cube intersectant en fonction de k
module dcube(k)
    {
        let (epc = dcub_ep(k))
        difference()
        {
            cube(r0plus);
            translate([epc, epc, epc]) cube(r0plus);
        }
    }    

//positionner 1/2 cube intersectant en fonctiond de k
module dcube_mv(k)
    {
        mvt = dcub_pos(k);
        intersection()
        {
            translate([mvt, mvt, mvt]) children();
            difference()
            {
                sphere(r0plus);
                sphere(r0*0.9);
            }
        }
    }

//créer et positionner la sérier de n+2 1/2 cubes
module dcube_series()
    {
        for (k = [0:1:n+1])
            dcube_mv(k) dcube(k);
    }

//créer 1/4 cylindre intersectant
module qcyl() 
    {   
    difference()
        {
            cylinder(h=2*r0plus, r=qcyl_ray, center=true);
            
            difference()
            {
                cube(3*r0plus, center=true);
                cube(r0plus);
            }
        }
    }
    
//positionner 1/4 cylindre intersectant en fonctiond de k et a
module qcyl_mv(k,a)
    {
        
        rotate(corner_rotang(k,a),corner_rotaxis(k,a))
        rotate(qcyl_prepos(a))
        children();
    }

//créer et positionner la série de 1/4 cylindres
module qcyl_series()
    {
        for(k = [1:1:n])
            for(a = [1:1:3])
                qcyl_mv(k,a) qcyl();
    }




//créer le bloc pour l'encoche
module encoche()
    {
        translate([0,0,r0plus/2]) rotate(-45) cube([5*encoch_pos, r3*ep1, r0plus], center = true);
    }
    
//positionner le bloc pour l'encoche
module encoche_pos()
    {
        translate(encoch_trans()) children();
    }
    
    
//créer et positionner l'encoche
module encoche_tot()
    {
        encoche_pos()
            encoche();
    }
    
//intersecter qqch avec le 1/8 sphere
module sphi_inter()
    {
        intersection()
        {
            sphi();
            children();
        }
    }

//enlever qqch du 1/8 sphere
module sphi_diff()
    {
        difference()
        {
            sphi();
            children();
        }
    }

//duplicate 4 times around z
module duplic_around()
    {
        for (count = [0:1:3])
            rotate(count * 90)
                children();
    }


duplic_around()
{color("Black")
    render() sphi_inter() 
        {
            dcube_series();
            qcyl_series();
            encoche_tot();
        }

color ("Peru")
    render() sphi_diff()
        {
            dcube_series();
            qcyl_series();
            encoche_tot();
        }
    }

color("Green")
    {
dcube_series();
qcyl_series();
encoche_tot();
    }



//Scénario
//créer la 1/2 sphère
//répéter n fois :
    //créer 4 demi-cubes, les positionner
//intersecter avec la 1/2 sphère

//répéter 3n fois :
    //créer 4 quarts de cylindre, les positionner
//intersecter avec la 1/2 sphere

//créer la pyramide pour le carré du bas, la positionner
//intersecter avec la 1/2 sphere

//faire tourner