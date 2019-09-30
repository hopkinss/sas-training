*------------------------------------------------------------------------*
| Exercise DATA01.01 
| 1) Read in the sashelp.class dataset for records where height is between 80 to 105 
| 2) Create 2 new variables: height_m and weight_kg from the height(in) and weight(lbs)
|    inches x .0254= m, lb x .045=kg
| 3) Derive a new variables called BMI using weight_kg / height_m(squared). round the value to 1 digit to right of decimal
| 4) Create a new label "Student BMI" for BMI variable
*------------------------------------------------------------------------*;
data bmi;
  label bmi='Student BMI';
  set sashelp.class(where=( 80 <= weight <=105));
  height_m = height*.0254;
  weight_kg=weight*.45;
  bmi = round(weight_kg / height_m**2,.1);
run;

*------------------------------------------------------------------------*
| Exercise DATA01.02
| 1) Display the Mean, Median, Mode, Min and Max for heigh_m, weight_kg, and BMI by Name
|    for the dataset created in DATA01.01
| 2) Capture the statistics displayed in results in DATA01.02 in an output 
|    dataset 
*------------------------------------------------------------------------*;
proc sort data=bmi;
  by name;
run;

proc means data=bmi  mean mode median min max;
  by name;
  var weight_kg height_m bmi;
    output out=summary;
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

data a b ab all;
  merge a(in=a) b(in=b);
  by id;
  if a then output a;
  if b and ^a then output b;
  if (a*b) then output ab;
  output all;
run;

*------------------------------------------------------------------------*
| Exercise DATA03.01
| Export sashelp.class as an excel spreadsheet (direct output here: O:\Projects_dev\training\data_step)
*-----------------------------------------------------------------------*;
proc export data=sashelp.class file="O:\Projects_dev\training\data_step\class.xlsx" replace dbms=xlsx;
run;

*------------------------------------------------------------------------*
| Exercise DATA03.02
| Read the excel file back into a SAS dataset
*------------------------------------------------------------------------*;
proc import datafile="O:\Projects_dev\training\data_step\class.xlsx" replace out=class dbms=xlsx;
  sheet='class';
  datarow=2;

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
data dm1;
  merge dm(in=a) dob;
  by subject;
  if a;
run;

* or *;

data dob(index=(subject));
  set dob;
run;

data dm1;
  set dm;
  set dob key=subject/unique;
  if _iorc_ then do;
    _error_=0;  
    call missing(dob);
  end;
run;
    
*------------------------------------------------------------------------*
| Exercise DATA07.02
| create an informat from dob. create dm2 and add subjects dob using the 
|    informat as a lookup
*------------------------------------------------------------------------*;
data dob_in;
  retain fmtname 'dob' type 'i';
  set dob(rename=(subject=start dob=label));
run;
 
proc format cntlin=dob_in;
run;

data dm2;
  format dob date9.;
  set dm;
  dob=input(subject,dob.);
run;

*------------------------------------------------------------------------*
| Exercise DATA07.03
| set dm1 by subject and see if the current subject is the oldest.
| capture the oldest subject and age  in new variables to compare with next row. after the last observation,
| create 2 macro variables called oldestSubject, oldest subject age in date9.
*------------------------------------------------------------------------*;
data _null_;
  set dm1 end=eof;
  by subject;
  retain oldsubject oldage;
  if _n_=1 then do;
    oldsubject=subject;
    oldage=dob;
  end;
  else do;
    if dob < oldage then do;
      oldsubject=subject;
      oldage=dob;    
    end;
  end;
  if eof then do;
    call symputx('oldestsubject',oldsubject);
    call symputx('oldage',put(oldage,date9.));
  end;
run;
  
%put old subject=&oldestsubject oldest age=&oldage;
