// ***************** LES CONSTANTES DECLAREES **************************************

// Constantes numériques utilitaires
sq3 = sqrt(3);

// Toute la calebasse est d'abord construite sur un huitième de sphère puis reproduit 4 fois pour faire la demi-shpère. A propos des triangles équilatéraux : on peut regarder chaque triangle équilatéral comme la différence entre 2 cubes dont le coin est entré dans un huitième de sphère. Ces deux cubes sont identiques mais translatés radialement selon un rayon qui va du centre de la sphère au centre de gravité du triangle plein central. Dans la suite, on appelle "épaisseur des traits des triangles équilatéraux la norme de cette translation.

// Nombre de triangles équilatéraux avec quarts de cercle.
n=3;

// Les triangles équilatéraux sont indexés par k :
// 0 pour la grande croix
// 1 à n-1 pour les triangles équilatéraux (ceux avec le petit arc de cercle)
// n pour le triangle plein.

// Rayon de la sphère initiale.
r0=100;

// Coefficient de détermination de l'épaisseur de la sphère (multiplie le rayon).
c_ep = 1 / 50;

// Coefficient multiplicateur de r0 indicant le grand rayon utilisé pour créer les blocs noirs avant intersection avec le huitième de sphère.
c1 = 1.1;

// Coefficient multiplicateur de r0 indicant le petit rayon utilisé pour créer les blocs noirs avant intersection avec le huitième de sphère.
c2 = 0.9;

// Taille minimale d'un fragment sur la sphère.
$fs = 1;

//Nombre minimum de degrés pour un fragment de cercle.
$fa = 5;
//$fs = 1; $fa=2; // temps d'exécution 4min 

// Les 4 rapports à l'épaisseur des triangles équilatéraux qui ensemble déterminent l'épaisseur des traits.
// Rapport entre l'espacement des traits des triangles équilatéraux et leur largeur.
r1 = 3;

// Rapport entre la largeur du trait de la grande croix et la largeur du trait des triangles équilatéraux.
r2 = 1.5;

// Rapport entre la largeur du trait du petit carré au fond et la largeur du trait des triangles équilatéraux
r3=1;

// Rapport entre la largeur du "trait" du triangle équilatéral plein central et la largeur du trait des triangles équilatéraux.
r4=3;

// Rapport entre le rayon de l'arc de cercle placé à l'angle des triangles équilatéraux et la largeur du trait des triangles équilatéraux.
r5=2;

// ***************** LES CONSTANTES DEDUITES **************************************

// Rayon agrandi pour créer les blocs noirs avant intersection avec le huitième de sphère.
r0plus = c1 * r0;

// Rayon diminué pour créer les blocs noirs avant intersection avec le huitième de sphère.
r0moins = c2 * r0;

// Epaisseur de la sphère.
ep = r0 * c_ep;

// Norme de la translation d'un cube intersectant la sphère pour créer la largeur du trait des triangles équilatéraux.
ep1 = r0 / sq3 / (n + (n + 1) * r1 + r2 + r4);

// Rayon d'un 1/4 cylindre servant à faire les coins.
qcyl_ray = r5 * ep1;

// Translation du trait du petit carré du fond selon les aces x et y pour atteindre sa position finale.
encoch_pos = (r2 + r1 / 2)* ep1 ;

// ***************** LES FONCTIONS **************************************

// Distance entre un cube intersectant la sphère pour le tracé extérieur d'un triangle équilatéral et chacun des trois plans du repère, en fonction de k.
function dcub_pos(k) = (k==0) ? 0 : ( ep1* (r2 + r1 + (k-1)*(1+r1)) ) ;

// Distance supplémentaire à dcub_pos pour la translation permettant le tracé intérieur.
function dcub_ep(k) = (k==0) ? (ep1*r2) :  (k==n+1) ? (ep1*r4) : ep1  ;

// Enumérer les épaisseurs de traits et les positions pour l'utilisateur.
for (k = [0:1:n+1])
{
    echo(str("k=0 : dcub_ep = ", dcub_ep(k), " , dcub_pos = ", dcub_pos(k)));
}

// Coordonnées du sommet intérieur du triangle équilatéral k le plus proche de l'axe a
function corner(k, a)=
    [
        let(d = dcub_pos(k) + dcub_ep(k))
        for (test = [1:1:3])
            (a==test) ? sqrt( pow(r0, 2) - 2 * pow(d, 2)) : d 
    ];

// Conversion du repérage d'un axe d'un nombre décimal à un nombre binaire. Exemple : l'axe 2 (soit l'axe y) devient (0,1,0).
function corner_axis(a) = [for (test = [1:1:3]) (a==test) ? 1:0];
    
// Axe de rotation pour atteindre le sommet du triangle k depuis l'axe a. C'est le produit vectoriel entre l'axe et le sommet.
function corner_rotaxis(k, a) = cross(corner_axis(a), corner(k, a));
        
// Angle de rotation pour atteindre le coin. On le trouve à partir du produit scalaire entre l'axe et le sommet.
function corner_rotang(k, a) = 
    acos(corner_axis(a) * corner(k, a) / norm(corner_axis(a)) / norm(corner(k, a)));

//  Angles de rotation d'un quart de cylindre à prépositionner sur l'axe a selon chacun des axes.
function qcyl_prepos(a) =
    (a==1) ? [90, 0, 90] : (a==2) ? [0,-90,-90] : [0,0,0] ;
    
// ***************** LES MODULES **************************************

// Créer le huitième de sphère initial.
module sphi()
{   
    difference()
        {
            difference()
            {
                sphere(r0);
                sphere(r0 - ep);
            }
            
            difference()
            {
                cube(2 * r0plus, center = true);
                cube(r0plus);
            }
        }
    }
    
// Créer le volume dont l'intersection avec le huitième de sphère constitue un triangle équilatéral. Il s'agit de la différence entre 2 cubes translatés l'un de l'autre.
module dcube(k)
    {
        epc = dcub_ep(k) ;
        difference()
        {
            cube(r0plus);
            translate([epc, epc, epc]) cube(r0plus);
        }
    }    

// Créer le volumne associé à un triangle équilatéral. Positionner le volume (dcube en l'occurrence) et l'intersecter avec la calebasse.
module dcube_mv(k)
    {
        mvt = dcub_pos(k);
        intersection()
        {
            translate([mvt, mvt, mvt]) children();
            difference()
            {
                sphere(r0plus);
                sphere(r0moins); 
            }
        }
    }

// Créer les n+2 triangles équilatéraux.
module dcube_series()
    {
        for (k = [0:1:n+1])
            dcube_mv(k) dcube(k);
    }

// Créer un tronçon de quart de cylindre.
module qcyl() 
    {   
    difference()
        {
            cylinder(h = 2 * r0plus, r = qcyl_ray, center = true);
            
            difference()
            {
                cube(3 * r0plus, center = true);
                cube(r0plus);
            }
        }
    }
    
// Positionner le quart de cylindre produit par qcyl en fonction de k (le triangle) et a (l'axe le plus proche).
module qcyl_mv(k,a)
    {        
        rotate(corner_rotang(k, a), corner_rotaxis(k, a))
        rotate(qcyl_prepos(a))
        children();
    }

// Créer et positionner la série de tous les quarts de cylindres.
module qcyl_series()
    {
        for(k = [1:1:n])
            for(a = [1:1:3])
                qcyl_mv(k,a) qcyl();
    }

// Créer le bloc pour le trait du petit carré au sommet.
module encoche()
    {
        translate([0, 0, r0plus / 2]) 
            rotate(-45) 
                cube([5 * encoch_pos, r3 * ep1, r0plus], center = true);
    }
    
// Positionner le bloc pour le trait du petit carré au sommet, créé par encoche.
module encoche_pos()
    {
        translate([encoch_pos, encoch_pos, 0]) children();
    }
    
    
// Association des modules encoche_pos et encoche.
module encoche_tot()
    {
        encoche_pos()
            encoche();
    }
    
// Intersecter un objet avec le huitième de sphere.
module sphi_inter()
    {
        intersection()
        {
            sphi();
            children();
        }
    }

// Faire la différence entre le huitième de shpère et un objet.
module sphi_diff()
    {
        difference()
        {
            sphi();
            children();
        }
    }

// Dupliquer 4 fois autour de l'axe z.
module duplic_around()
    {
        for (count = [0:1:3])
            rotate(count * 90)
                children();
    }

// ***************** LA CALEBASSE **************************************

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

//color("Green")
//    {
//dcube_series();
//qcyl_series();
//encoche_tot();
//    }



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