* Encoding: UTF-8.
**********************************************************************************
*                           DATA CLEANING SYNTAX                                                                      *
*   This syntax accompanies the Personality Processes Lab                                           *
*   manual for running & analysing an ESM study. Refer to the                                     *
*   pdf or https://github.com/jesssun/esm-manual for full details.                             *                                            
**********************************************************************************

*Change the working directory.
*You need to edit this path to the folder you're working out of

cd '/Users/Jessie/Dropbox/ESM MLM Manual/Data Files/Data Preparation'.

**********************************************************************************
*                     1. Identifying mistyped baseline IDs                       *
**********************************************************************************

*Have both the baseline and ESM files open

*Make a copy of the baseline file.

SAVE OUTFILE='EPA_ESM_3_Baseline_Copy.sav'.

*Note that the DATASET ACTIVATE commands assume that
*Dataset 1 is the baseline file and Dataset 2 is the ESM file
*This may not be the case if you opened them in a different order
*or if you had other datasets open already.
*You can also just manually click on the respective data windows to
*activate them.

*Sort baseline file copy by id

DATASET ACTIVATE DataSet1.
SORT CASES BY id(a).

*Sort ESM file by id

DATASET ACTIVATE DataSet2.
SORT CASES BY id(a).

*Bringing the baseline file to the front

DATASET ACTIVATE DataSet1.

*Merge the two files matching by id
*Make sure the ESM file is 'DataSet2' or change it to the appropriate Dataset

MATCH FILES /TABLE=* 
  /FILE='DataSet2' 
  /BY id. 
EXECUTE.

*If you use the point & click interface:
*Data > Merge Files > Add variables
*Select:
*-Match cases on key variables
*-Cases are sorted in order of key variables in both datasets
*-Both files provide cases
*Move id to Key Variables

*In the new merged file, sort one of the ESM variables ascending

SORT CASES BY sit(a).

*The first few cases show you the baseline responses that have no ESM data
*Suggests that the ID was mistyped at baseline

*Here are the correct ones for this study, which you need to fix in the ORIGINAL baseline file.
*First, open the ORIGINAL baseline file (EPA_ESM_1_Baseline.sav)

GET
  FILE='EPA_ESM_1_Baseline.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.

IF id = '111111' id = '06AAYCZY'.
IF id = '123456' id = '06OBABZQ'.
IF id = 'anon' id = 'PMQNPX'.
IF id = 'D8U0L8' id = '06YDZRFO'.
EXECUTE.

*Let's also now mark participants who dropped out for technical/other reasons in the baseline file.

COMPUTE droppedbug = 0.
IF id = 'HTRD0S' or id = 'X838RV' or id = 'M0ET4I' or id= 'D22Y7M'
or id = 'JKW6JO' or id = 'H9PZ8F' or id = 'MY4HSC' or id = '6RD4Q8'
droppedbug = 1.
EXECUTE.

COMPUTE badparticipant=0.
IF id = '210J95' badparticipant = 1.
EXECUTE.

*This new variable marks reports as valid initially. We can then set it to "0" (invalid) for various reasons:

COMPUTE valid = 1.
IF droppedbug = 1 or badparticipant = 1 valid = 0.
EXECUTE.

*Save the baseline file as a correct file. 
*Note that we no longer need the merged file (EPA_ESM_3_Baseline_Copy.sav) we just created as it's incorrect

SAVE OUTFILE='EPA_ESM_4_Baseline_Flagged.sav'.

**********************************************************************************
*         2. Identifying ESM responses from non-participants           *
**********************************************************************************

*Activate the ESM file and make a copy
*Again, assumes that the ESM file is DataSet2 
*and the baseline (corrected) file is DataSet1

DATASET ACTIVATE DataSet2.

SAVE OUTFILE='EPA_ESM_5_Merged.sav'.

*Working from this copy, merge the ESM file with the corrected baseline file.

*Sort both files by id

SORT CASES BY id(a).

DATASET ACTIVATE DataSet1.

SORT CASES BY id(a).

*To merge, activate the ESM file copy

DATASET ACTIVATE DataSet2.

MATCH FILES /FILE=* 
  /TABLE='DataSet1' 
  /BY id. 
EXECUTE.

*Or, point & click instructions:
*Data > Merge Files > Add variables
*Select:
*-Match cases on key variables
*-Cases are sorted in order of key variables in both datasets
*-Non-active dataset is keyed table
*Move id to Key Variables

*In this merged file, sort one of the baseline variables by ascending

SORT CASES BY age(a).

*You can now see the ESM responses that are not matched with any baseline data
*So they're not part of this study
*If you manually move the trait variables to the top of the variable list, it's easier to see this

*Make a note of all of these unmatched ESM ids and flag them in the file

COMPUTE nobaseline = 0.
IF id = '03YAKC' or id = '06BGXCCF' or id = '06DZEFYM' or id =
'06FFYUPA' or id = '06FTOFZY' or id = '06IOTKBG'
or id = '06IUYGPU' or id = '06KVFOUK' or id = '06MSYWUJ' or id =
'06NRGTEE' or id = '06NUSVXU' or id = '06PUSSCL'
or id = '06RKCAMG' or id = '06SRKBPO' or id = '06YTACLY' or id =
'19XB39' or id = '738TQV' or id = 'FRIYWJ'
or id = 'INZ09U' or id = 'QHUX90' or id = 'SPCCG0' or id = 'YL18D7'
or id = '06KQJGCD' nobaseline = 1.
EXECUTE.

*Flag the "nobaseline" responses as invalid

IF nobaseline = 1 valid = 0.
EXECUTE.

*Save this file

SAVE OUTFILE='EPA_ESM_5_Merged.sav'.

*Then save a new copy

SAVE OUTFILE='EPA_ESM_6_Excluded.sav'.

*Now we're going to get rid of the invalid reports to date

SELECT IF valid = 1.
EXECUTE.

*This is a good point to summarise the total no. actual participants who completed the study
*and the total no. reports they completed.

*This command identifies duplicate cases of id. 

SORT CASES BY id(a).
MATCH FILES
/FILE=*
/BY id
/LAST=PrimaryLast.
VARIABLE LABELS PrimaryLast 'Indicator of each last matching case as Primary'.
VALUE LABELS PrimaryLast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL PrimaryLast (ORDINAL).
FREQUENCIES VARIABLES=PrimaryLast.
EXECUTE.

*In the output, Total = total number of reports; Primary Cases = no. participants
*It should be 67 participants with 1934 reports

**********************************************************************************
*               3. Screening individual reports for problems               *
**********************************************************************************

*Too many identical responses in individual reports?
*This syntax counts the number of 0's, 1's, 2's, etc. in each report

COUNT NumZeros=ex1 to cont3 (0).
COUNT NumOnes=ex1 to cont3 (1).
COUNT NumTwos=ex1 to cont3 (2).
COUNT NumThrees=ex1 to cont3 (3).
COUNT NumFours=ex1 to cont3 (4).
COUNT NumFives=ex1 to cont3 (5).
COUNT NumSixes=ex1 to cont3 (6).
COUNT NumSevens=ex1 to cont3 (7).
COUNT NumEights=ex1 to cont3 (8).
COUNT NumNines=ex1 to cont3 (9).
COUNT NumTens=ex1 to cont3(10).
EXECUTE.

*This syntax flags reports that have 12 or more identical responses (i.e., > 85% identical)

COMPUTE tooidentical=0.
IF NumZeros > 11
OR NumOnes > 11
OR NumTwos > 11
OR NumThrees > 11
OR NumFours > 11
OR NumFives > 11
OR NumSixes > 11
OR NumSevens > 11
OR NumEights > 11
OR NumNines > 11
OR NumTens > 11 tooidentical=1.
EXECUTE.

*Marking tooidentical reports as invalid

IF tooidentical = 1 valid = 0.
EXECUTE.

*Count how many reports are "tooidentical"

FREQUENCIES tooidentical.

*31 reports that are too identical

*We're now going to remove participants with too few valid responses

*This counts the number of valid reports (after filtering out tooidentical reports)

FILTER BY valid.

AGGREGATE
/OUTFILE=* MODE=ADDVARIABLES
/BREAK=id
/responsecount=N(id).

COMPUTE toofewtotal = 0.
IF responsecount < 15 toofewtotal = 1.
EXECUTE.

IF toofewtotal = 1 valid = 0.
EXECUTE.

*Saving this file - exclusions flagged (as valid = 0) but not deleted

USE ALL.
SAVE OUTFILE='EPA_ESM_6_Excluded.sav'.

*Save a new version

SAVE OUTFILE='EPA_ESM_7_Valid.sav'.

*Use the SELECT IF command to remove invalid cases

SELECT IF valid = 1.
EXECUTE.

*Updated descriptives

DELETE VARIABLES PrimaryLast.
MATCH FILES
/FILE=*
/BY id
/LAST=PrimaryLast.
VARIABLE LABELS PrimaryLast 'Indicator of each last matching case as Primary'.
VALUE LABELS PrimaryLast 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL PrimaryLast (ORDINAL).
FREQUENCIES VARIABLES=PrimaryLast.
EXECUTE.

*Final = 62 participants with 1841 reports

*Get descriptives on response count and participant demographics

FILTER BY PrimaryLast.
DESCRIPTIVES responsecount.

DESCRIPTIVES age.
FREQUENCIES gender.

*Save the current file and then save a copy

USE ALL.
SAVE OUTFILE='EPA_ESM_7_Valid.sav'.
SAVE OUTFILE='EPA_ESM_8_Final.sav'.

**********************************************************************************
*                    4. Computing and Centring Variables                     *
**********************************************************************************

*Recoding reverse-scored items

RECODE
ex4 ex6 (0=10) (1=9) (2=8) (3=7) (4=6) (5=5) (6=4) (7=3) (8=2)
(9=1) (10=0) INTO ex4r ex6r.
EXECUTE.

*Computing scales

COMPUTE e = mean (ex1, ex2, ex3, ex4r, ex5, ex6r).
COMPUTE pa = mean (pa1, pa2, pa3).
COMPUTE cont = mean (cont1, cont2, cont3).
COMPUTE pow = mean (pow1, pow2).
EXECUTE.

*Create aggregate state variables

SORT CASES BY id(A).
AGGREGATE
/OUTFILE=* MODE=ADDVARIABLES OVERWRITE=YES
/BREAK=id
/eav=MEAN(e)
/paav=MEAN(pa)
/contav=MEAN(cont)
/powav=MEAN(pow).

*Computing centred state variables

COMPUTE est=e-eav.
COMPUTE past=pa-paav.
COMPUTE contst=cont-contav.
COMPUTE powst=pow-powav.
EXECUTE.

*Computing effect-coded situation variables

COMPUTE social=0.
IF sit=2 social=1.
IF sit=0 social=-1.
EXECUTE.

COMPUTE semi=0.
IF sit=1 semi=1.
IF sit=0 semi=-1.
EXECUTE.

**********************************************************************************
*                   5. Working with date-time information                     *
**********************************************************************************

*See p. XX of the manual for next steps on using Excel to work with date/time info

COMPUTE dt = 0.
EXECUTE.

*Copy the dt column from the Excel spreadsheet & paste it into this new variable

*Now we're going to create time elapsed variables

SORT CASES BY id(a) dt(a).

*See manual for Excel instructions

*Computing variable that tells us when participants completed their first report

COMPUTE startdt = 0.
EXECUTE.

*Manually copy & paste column C from Excel spreadsheet into this new variable

*Computing time elapsed since start of study

COMPUTE timeel = dt-startdt.
EXECUTE.

*Creating standardised version to use as covariate in Mplus

DESCRIPTIVES timeel /SAVE.

**********************************************************************************
*                       6. Getting the file ready for Mplus                        *
**********************************************************************************

*Z-scoring trait extraversion
*First save a new file

SAVE OUTFILE='EPA_ESM_8_Final.sav'.
SAVE OUTFILE='EPA_ESM_9_Level2.sav'.

SELECT IF PrimaryLast = 1.
EXECUTE.

DESCRIPTIVES extrav /SAVE.

*Disaggregate this to the Final file

*Open the Final file (EPA_ESM_8_Final.sav)

GET
  FILE='EPA_ESM_8_Final.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.

*Sort both files
*Syntax assumes that DataSet1 is the final file whereas DataSet2 is the Level2 file

DATASET ACTIVATE DataSet1.
SORT CASES BY id(a).
DATASET ACTIVATE DataSet2.
SORT CASES BY id(a).

*Activate the Final file

DATASET ACTIVATE DataSet1.

*Syntax

MATCH FILES /FILE=* 
  /TABLE='DataSet2' 
  /RENAME (badparticipant cont cont1 cont2 cont3 contav contst date datetime droppedbug dt e eav 
    est ex1 ex2 ex3 ex4 ex4r ex5 ex6 ex6r PrimaryLast nobaseline NumEights NumFives NumFours NumNines 
    NumOnes NumSevens NumSixes NumTens NumThrees NumTwos NumZeros pa pa1 pa2 pa3 paav past pow pow1 
    pow2 powav powst responsecount semi sit social startdt surveyend surveystart time timeel 
    toofewtotal tooidentical extrav valid Age Gender Ztimeel = d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 
    d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 
    d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 
    d61) 
  /BY id 
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 
    d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37 d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 
    d50 d51 d52 d53 d54 d55 d56 d57 d58 d59 d60 d61. 
EXECUTE.

*Point & click instructions:
*Data > Merge Files > Add variables
*Select:
*-Match cases on key variables
*-Cases are sorted in order of key variables in both datasets
*-Non-active dataset is keyed table
*Move id to Key Variables

*Creating numerical ids from string variable

SORT CASES BY id(a) dt(a).
RENAME VARIABLES id = stringid.

*First, index observations for each person, where 1 = a participant's first report

COMPUTE obs = 1.
IF stringid = lag(stringid) obs = lag(obs) + 1.
EXECUTE.

*Using that info to create a numerical id

COMPUTE #x = #x + 1.
IF obs ne 1 #x = lag(#x).
COMPUTE id = #x.
EXECUTE.

*Save the final file

SAVE OUTFILE='EPA_ESM_8_Final.sav'.

*Change first part of working directory to wherever you've saved these files

cd '/Users/Jessie/Dropbox/ESM MLM Manual/Data Files/Mplus Files/Key Analyses'.

*Exporting a .csv file with only the variables we want

SAVE TRANSLATE OUTFILE= 'epa_example.csv'
/KEEP= id zextrav e pa cont pow est past powst contst 
             Ztimeel social semi
/TYPE=CSV
/ENCODING='UTF8'
/MAP
/REPLACE
/CELLS=VALUES.

**********************************************************************************
*                       7. Bonus: Computing lagged variables                                                    *
**********************************************************************************

*Compute a lagged variable set values on the lagged variable as missing if 
*1) the id at the current time point (dt) is different (ne) from the id at the previous time point (lag(dt), and if
*2) the two reports are more than 1/6 of a day (i.e., 4 hours) apart.

IF (id=lag(id)) elag=lag(est).
IF $casenum = 1 or id ne lag(id) or dt-lag(dt) > (1/6) elag = ($SYSMIS).
IF (id=lag(id)) powlag=lag(powst).
IF $casenum = 1 or id ne lag(id) or dt-lag(dt) > (1/6) powlag = ($SYSMIS).
IF (id=lag(id)) contlag=lag(contst).
IF $casenum = 1 or id ne lag(id) or dt-lag(dt) > (1/6) contlag = ($SYSMIS).
IF (id=lag(id)) palag=lag(past).
IF $casenum = 1 or id ne lag(id) or dt-lag(dt) > (1/6) palag = ($SYSMIS).
EXECUTE.

*Remove lines of data with missing values	

COMPUTE lagged = 1.
IF elag = ($SYSMIS) lagged = 0.
EXECUTE.

SAVE OUTFILE='EPA_ESM_10_BonusLagged.sav'.
SELECT IF lagged = 1.
EXECUTE.

**********************************************************************************
*                       8. Syntax for spaghetti and individual plots                                            *
**********************************************************************************

*Spaghetti plot

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=est past id MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: est=col(source(s), name("est"))
  DATA: past=col(source(s), name("past"))
  DATA: id=col(source(s), name("id"), unit.category())
  GUIDE: axis(dim(1), label("State Extraversion"))
  GUIDE: axis(dim(2), label("State PA"))
  GUIDE: legend(aesthetic(aesthetic.color.exterior), label("id"))
  ELEMENT: point.jitter(position(est*past), transparency.exterior(transparency."0.7"), size(size."3"))
  ELEMENT: line(position(smooth.linear(est*past)), split(id), transparency(transparency."0.7"))
END GPL.

*Individual plots

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=est past id[LEVEL=NOMINAL] MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1200px,1200px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: est=col(source(s), name("est"))
  DATA: past=col(source(s), name("past"))
  DATA: id=col(source(s), name("id"), unit.category())
  COORD: rect(dim(1,2), wrap())
  GUIDE: axis(dim(1))
  GUIDE: axis(dim(2))
  GUIDE: axis(dim(3), opposite())
  ELEMENT: line(position(smooth.linear(est*past*id)), color(color.black))
  ELEMENT: line(position(smooth.loess(est*past*id)), color(color.red))
  PAGE: end()
END GPL.

**********************************************************************************
*                       9. Export individual items for omega reliability analyses                        *
**********************************************************************************

*Change first part of working directory to wherever you've saved these files

cd '/Users/Jessie/Dropbox/ESM MLM Manual/Data Files/Mplus Files/Reliability'.

*Export id, obs, and individual items

SAVE TRANSLATE OUTFILE= 'epa_items.csv'
/KEEP= id obs ex1 ex2 ex3 ex4r ex5 ex6r
pa1 pa2 pa3 pow1 pow2 cont1 cont2 cont3
/TYPE=CSV
/ENCODING='UTF8'
/MAP
/REPLACE
/CELLS=VALUES.




