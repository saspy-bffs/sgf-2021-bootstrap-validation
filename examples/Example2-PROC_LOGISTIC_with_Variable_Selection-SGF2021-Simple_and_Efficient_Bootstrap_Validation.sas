/*
A Framework for Simple and Efficient Bootstrap Validation in SAS®, with Examples

Example 2: PROC LOGISTIC with Variable Selection - Invited Paper -  SAS Global Forum 2021

This notebook contains an executable version of the example in Appendix C of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation.
*/



/*
Pre-example Setup Part 1

The code below creates macro variables encapsulating model parameters. Only SAS log output should be created.

**Note**: You may also wish to change the values of the macro variables in order to explore bootstrap validation for different models. This example is adapted from Module 10 at https://wwwn.cdc.gov/nchs/nhanes/tutorials/samplecode.aspx
*/
%let response_variable_condition = bpxsar >= 140 OR bpxdar >= 90 OR bpq050a = 1;
%let response_variable = hyper;
%let outcome = &response_variable.(EVENT='1');
%let class_variables = bpq100d dmq051 dmd110;
%let predictor_variables = lbxtc bpq100d bmxbmi ridageyr lbxtr dmq051 dmd110 indhhinc indfmpir;



/*
Pre-example Setup Part 2

The code below downloads the example dataset for Module 10 at https://wwwn.cdc.gov/nchs/nhanes/tutorials/samplecode.aspx. Only SAS log output should be created.
*/ 
filename tempfile "%sysfunc(pathname(work))/analysis_data.sas7bdat";
proc http
        url='https://wwwn.cdc.gov/nchs/data/tutorials/analysis_data.sas7bdat'
        method='get'
        out=tempfile
    ;
run;



/*
Pre-example Setup Part 3

The code below subsets the dataset downloaded above to rows with no missing values for the predicator variables, as well as creating a response variable. Only SAS log output should be created.
*/
data example_dataset;
    set analysis_data;
    
    * Create outcome variable;
    if (&response_variable_condition.) then &response_variable. = 1;
    else &response_variable. = 0;
    
    * Subset to observations with no missing values for outcome variable or predictor variables;
    if nmiss(&response_variable., %sysfunc(tranwrd(&predictor_variables.,%str( ),%str(,)))) = 0;
    
    keep &response_variable. &predictor_variables.;
run;



/*
Step 1: Train a Model

See page 13 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only PROC LOGISTIC output should be created.
*/
ods output Association=model_association_table(
    where=(Label2='c')
    keep=Label2 nValue2
    rename=(nValue2=original_model_c_statistic)
);
proc logistic data=example_dataset;
    class &class_variables.;
    model &outcome. = &predictor_variables.
        / selection=backward slstay=0.1 fast
    ;
run;



/*
Step 2: Generate Bootstrap Samples
 
See page 5 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only PROC SURVEYSELECT output should be created.
*/
proc surveyselect
        data=example_dataset
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

See pages 13-14 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only SAS log output should be created.
*/

* turn off all output;
ods graphics off;
ods exclude all;
ods noresults;

* Trains models on all 500 bootstrap samples, capturing the resulting C-statistics;
ods output Association=bootstrap_association_table(
    where=(Label2='c')
    keep=Replicate Label2 nValue2
    rename=(nValue2=c_statistic_value)
);
proc logistic data=bootstrap_samples outmodel=bootstap_models;
    by Replicate;
    class &class_variables.;
    model &outcome. = &predictor_variables.
        / selection=backward slstay=0.1 fast
    ;
run;



/*
Step 4: Test Bootstrap Models

See page 7 of the paper at https://github.com/saspy-bffs/sgf-2021-bootstrap-validation. Only SAS log output should be created.
*/

* Score original dataset with bootstap models;
ods output Scorefitstat=bootstrap_scores(
    keep=Replicate AUC
    rename=(AUC=c_statistic_value)
);
proc logistic inmodel=bootstap_models;
    score
        data=example_dataset
        fitstat
    ;
    by Replicate;
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
