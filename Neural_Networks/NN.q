/ Program to analyze human behaviour and gnome evolution
/ define population
.ga.good:100;
.ga.evil:100;

/ resource i.e food etc
.ga.foodavailable:500;

/ Prepare gnome base characterstics
.ga.gnome:.ga.good#update tipe:`good,food:1.0,energy:0.0 from 
  .ga.chars:enlist .[!]flip (
  (`aggression;.2);
  (`sharing;.5);
  (`fight;.1);
  (`speed;.25)
  );

.ga.gnome,:.ga.evil#update tipe:`evil,food:1.5,energy:0.0 from 
  enlist .[!]flip (
  (`aggression;.3);
  (`sharing;.1);
  (`fight;.4);
  (`speed;.25)
  );

.ga.rules.contend:`tipe`opponent`energylost!/:(
 (`good;`good;0);
 (`good;`bad;0.5);
 (`bad;`good;0.5);
 (`bad;`bad;1)
 );

.ga.gnome:2!`id`gen`isalive`food xcols update id:i,gen:1,isalive:1b,food:0,msg:` from .ga.gnome;
.ga.learning:.01;
.ga.learningMultipler:2; / to pass to next gen
.ga.maxScore:10; / max capability of evolution of gnome
.ga.rollSpeed:00:00:02; / 2 seconds pause before upgrading generation
/ Now population is ready. Lets create playground and rules
.ga.currentGen:1;
fupdscore:{update score:aggression+sharing+fight+speed from `.ga.gnome where gen=.ga.currentGen;}

finit:{
}
fStackGnomes:{
  fupdscore[];
  / Filter gnomes that have no energy left
  / update isalive:0b,msg:`no_energy_left from `.ga.gnome where gen=.ga.currentGen,isalive=1b,energy<0;
  currGenGnomes:select from .ga.gnome where gen=.ga.currentGen,isalive=1b;
  / filter out those who have already reached target energy levels
  currGenGnomes:select from currGenGnomes where energy<food;
  / foodneeded:exec sum food from currGen;
  currGenGnomes:`score xdesc count[currGenGnomes]?currGenGnomes;  / randomize and sort
  .ga.gnomeToPlay:select from currGenGnomes where .ga.foodavailable < sums (food-energy);
  / The rest are marked dead because of no food available
  update isalive:0b,msg:`unfit_for_generation from `.ga.gnome where gen=.ga.currentGen,not energy>=food,not id in exec id from .ga.gnomeToPlay;
 };
.log.info:.log.error:.log.warn:{0N!(.z.p;-3!x)};
.jobs.upd:{[a;b;c;d;e]0N!(a;b;c;d;e)};
.ga.moveGeneration:{
  / if all alive have reached desired energy levels while there is still food left, then move gen
  if[0=exec count i from .ga.gnome where gen=.ga.currentGen,isalive=1b,energy<food;
     .log.info"Upgrading generation";
     .ga.currentGen:.ga.currentGen+1;
     upsert[`.ga.gnome;update energy:0,gen:.ga.currentGen from select from .ga.gnome where gen=.ga.currentGen-1,isalive=1b,energy>=food];
   .jobs.upd[`sleep;.z.p+.ga.rollSpeed;`fStackGnomes;::;0D];
   ];
 };

.ga.groupAndPlay:{
  / make groups of 2 each from .ga.gnomeToPlay
  / call .ga.applyRrules for each group
  / repeat play
  fStackGnomes[];
 };

.ga.applyRules:{
 / get data of two contendors
 / get rules of energy lost
 / find winners and losers
 / update .ga.foodavailable
 / if energy lost is 0 then randomize
 / update winning reason and upgrade
 / update failure reason and upgrade
 / upsert .ga.gnome using .ga.gnomeToPlay
 };

2 xgroup .ga.gnome


/
select from .ga.gnome where 8>sums ?[tipe=`good;1;1.5]
fupdscore[]
.ga.gnome