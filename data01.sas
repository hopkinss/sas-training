*------------------------------------------------------------------------*
| Exercise DATA01.01 
| 1) Read in the mydata.class dataset for records where weight is between 80 to 105 
| 2) Create 2 new variables: height_m and weight_kg from the height(in) and weight(lbs)
|    inches x .0254= m, lb x .045=kg
| 3) Derive a new variables called BMI using weight_kg / height_m(squared)
| 4) Create a new label "Student BMI" for BMI variable
*------------------------------------------------------------------------*;
libname mydata 'E:\Program Files\SAS\SASFoundation\9.4\core\sashelp' access=readonly;



data A;
label bmi='Student BMI';
  set mydata.class(where=(80 < weight <105));
  
  height_m=height*.0254;
  weight_kg=weight*.45;
  bmi=weight_kg/height_m**2;
  
run;


*------------------------------------------------------------------------*
| Exercise DATA01.02
| 1) Display the Mean, Median, Mode, Min and Max for heigh_m, weight_kg, and BMI
|    for the dataset created in DATA01.01
| 2) Capture the statistics displayed in results in DATA01.02 in an output 
|    dataset 
*------------------------------------------------------------------------*;

proc means data=a mean median mode min max;
  var height_m weight_kg bmi;
  output out=b  n=n mean=mean median=median mode=mode 
                                        min=min max=max ;
run;


*------------------------------------------------------------------------*
| Exercise DATA02.01
| 1) Run the code to generate datasets A and B
| 2) Join A and B by ID to create 3 datasets 
     2.1) AB - all records in both A and B
     2.2) A - records that exist in A
     2.3) B - records that only exist in B
     2.4) ALL - all the records in both datasets
*------------------------------------------------------------------------*;

data A;
  do ID = 2 to 20 by 2;
    output;
  end;
run;

data B;
  do ID = 1 to 20;
    output;
  end;
run;

proc print data=a;run;
proc print data=b;run;

data ab;
  merge a (in=a) b (in=b);
  by id;
  if a*b;
run;

data a;
  merge a (in=a) b (in=b);
  by id;
  if a;
run;

data b;
  merge a (in=a) b (in=b);
  by id;
  if b and ^a;
run;

data all;
  merge a (in=a) b (in=b);
  by id;
run;


*------------------------------------------------------------------------*
| Exercise DATA03.01
| Export mydata.class as an excel spreadsheet (direct output here: O:\Projects_dev\training\data_step)
*------------------------------------------------------------------------*;

proc export data=mydata.class
                file="O:\Projects_dev\training\data_step\class.xlsx"
                dbms=xlsx replace; 
run;



*------------------------------------------------------------------------*
| Exercise DATA03.02
| Read the excel file back into a SAS dataset
*------------------------------------------------------------------------*;

%let fn=O:\Projects_dev\training\data_step\class.xlsx;
proc import datafile= "&fn" 
out=class_conv
dbms=xlsx replace; 
run;

*------------------------------------------------------------------------*
| Exercise DATA04.01
| -run the setup code to get the dataset
| 1) Parse the variable USUBJID into Site (middle component) and Subjid (right of -)
| 2) assign TRT=A to Sites <= 20, TRT=B for >20
| 3) Output trt A into dataset A, trt into data set B
*------------------------------------------------------------------------*;
data patient;
  do i = 1 to 40;
    USUBJID='sgxx'||'-'||put(i,z3.)||'-'||put(i*200,z4.);
    output;
  end;
run;

data a b;
  set patient (drop=i);
  site=input(scan(usubjid,2,'-'),8.);
  subjid=scan(usubjid,3,'-');
  if site<=20 then trt='A';
  else if site>20 then trt='B';
  if trt='A' then output a;
  else if trt='B' then output b;
run;
 

*------------------------------------------------------------------------*
| Exercise DATA05.01
| 1) read in mydata.cars
| 2) subset the output dataset for records where model has the 'word' LX in it
| 3) sort it with not duplicates by make, but capture the duplicates in a separatate dataset
*------------------------------------------------------------------------*;

data a;
  set mydata.cars;
  if index (model,"LX");
run;

proc sort data=a
  out=b nodupkey;
  by make;
run;




*------------------------------------------------------------------------*
| Exercise DATA06.01
| 1) read in mydata.baseball data
| 2) subset for boston redsox
| 3) transpose 'Career Home Runs' by player name
*------------------------------------------------------------------------*;

proc sort data=mydata.baseball (where=(team='Boston'))
  out=boston ;
  by name;
run; 

proc transpose data=boston out=homerun prefix=hr_;
 * by name;
  id name;
  var crhome;
run;

data test;
 set homerun;
 array _hr[*] hr_:;
 total = sum(of _hr[*]);
run;

*------------------------------------------------------------------------*
| Setup for DATA07 - submit the 2 datasets
*------------------------------------------------------------------------*;
data dob;
  format dob date9.;
  do subject = 1 to 10;
    dob=today() - round(ranuni(0)*10000,1);
    output;    
  end;
run;

data dm;
  do subject=1 to 10;
    output;
  end;
run;

*------------------------------------------------------------------------*
| Exercise DATA07.01
| create DM1 dataset and add the subject's dob from dob
*------------------------------------------------------------------------*;


*------------------------------------------------------------------------*
| Exercise DATA07.02
| create an informat from dob. create dm2 and add subjects dob using the 
|    informat as a lookup
*------------------------------------------------------------------------*;


*------------------------------------------------------------------------*
| Exercise DATA07.03
| set dm1 by subject and see if the current subject is the oldest.
| capture the oldest subject and age  in new variables to compare with next row. after the last observation,
| create 2 macro variables called oldestSubject, oldest subject age in date9.
*------------------------------------------------------------------------*;



















