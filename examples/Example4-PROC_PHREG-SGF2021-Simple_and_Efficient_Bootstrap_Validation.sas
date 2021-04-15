/*
A Framework for Simple and Efficient Bootstrap Validation in SAS®, with Examples

Example 4: PROC PHREG - Invited Paper -  SAS Global Forum 2021

This notebook contains an executable version of the example in Appendix E of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation.
*/



/*
Pre-example Setup

The code below downloads the example dataset for the tutorial "Introduction to Survival Analysis in SAS" at https://stats.idre.ucla.edu/sas/seminars/sas-survival/. Only SAS log output should be created.
*/
filename whas500 "%sysfunc(pathname(work))/analysis_data.sas7bdat";
proc http
        url='https://stats.idre.ucla.edu/wp-content/uploads/2016/02/whas500.sas7bdat'
        method='get'
        out=whas500
    ;
run;


/*
Step 1: Train a Model

See page 16-17 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only PROC PHREG output should be created.
*/
ods output concordance=model_association_table(
    keep=estimate
    rename=(estimate=original_model_c_statistic)
);
proc phreg data=analysis_data concordance;
    class gender;
    model lenfol*fstat(0) = gender age;
run;



/*
Step 2: Generate Bootstrap Samples
 
See page 5 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only PROC SURVEYSELECT output should be created.
*/
proc surveyselect
        data=analysis_data
        out=bootstrap_samples
        seed=1354687
        method=urs
        outhits
        rep=500
        samprate=1
    ;
run;


/*
Step 3: Train Models in Each Bootstrap

See page 17 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only SAS log output should be created.
*/

* turn off all output;
ods graphics off;
ods exclude all;
ods noresults;

ods output concordance=bootstrap_association_table(
    keep=replicate estimate
    rename=(estimate=c_statistic_value)
);
proc phreg data=bootstrap_samples concordance;
    by replicate;
    class gender;
    model lenfol*fstat(0) = gender age;
    store coxmodel;
run;


/*
Step 4: Test Bootstrap Models

See page 17-18 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only SAS log output should be created.
*/

proc plm restore=coxmodel;
    score data=analysis_data out=scored_data(keep=replicate id lenfol fstat predicted);
run;

proc sql noprint;
    select count(*)
        into :totobs
        from analysis_data;
quit;

data bootstrap_scores(keep=replicate nch ndh pairs c_statistic_value);
    set scored_data(
        keep=replicate id predicted lenfol fstat
        where=(fstat=1)
        rename=(id=idn_i predicted=y_i lenfol=x_i)
    );
    by replicate;
    if first.replicate then do;
        nch = 0;
        ndh = 0;
        pairs = 0;
    end;
    do i=1+((replicate-1)*&totobs) to replicate*&totobs;
        set scored_data(
            keep=id predicted lenfol
            rename=(id=idn_j predicted=y_j lenfol=x_j)
        ) point=i;
        if idn_i NE idn_j and x_i < x_j then do;
            if y_i > y_j then
                nch + 1;
            else if y_i EQ y_j then
                nch + 0.5;
            else if x_i < x_j then
                ndh + 1;
            pairs + 1;
        end;
    end;
    if last.replicate then do;
        c_statistic_value=nch/pairs;
        output;
    end;
run;

* turn output back on;
ods results;
ods select all;
ods graphics on;



/*
Step 5: Estimate Optimism

See page 8 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only SAS log output should be created.
*/
proc sql;
    create table model_optimism as
        select
            avg(A.c_statistic_value - B.c_statistic_value) as optimism
        from
            bootstrap_association_table as A
            inner join
            bootstrap_scores as B
            on A.Replicate = B.Replicate
    ;
quit;


/*
Step 6: Adjust Performance with Optimism

See page 9 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only PROC PRINT output should be created.
*/

* assemble C-statistic for original model, optimism, and corrected C-statistic into a 1x3 table;
data corrected_model_evaluation;
    set model_association_table;
    set model_optimism;
    
    corrected_c_statistic = original_model_c_statistic - optimism;

    label
        original_model_c_statistic = 'Naive C-Statistic'
        optimism = 'Optimism'
        corrected_c_statistic = 'Optimism-Corrected C-Statistic'
    ;
    
    keep original_model_c_statistic optimism corrected_c_statistic;
run;

* print final results;
proc print
        data=corrected_model_evaluation
        noobs
        label
    ;
run;
