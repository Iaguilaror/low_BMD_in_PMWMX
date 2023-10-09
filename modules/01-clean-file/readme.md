# clean-file  
**Author(s):**

* Israel Aguilar-Ordoñez (iaguilaror@gmail.com)

**Date:** June 2023  

---

## Module description:  

A (DSL2) Nextflow module to clean and simplify proteomic data from a Synapt G2-Si Mass Spectrometer

## Module Dependencies:
| Requirement | Version  | Required Commands |
|:---------:|:--------:|:-------------------:|
| [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) | 22.10.4 | nextflow |
| [R](https://www.r-project.org/) | 4.2.2 | Rscript |

# R packages required:

```
dplyr version: 1.1.2
openxlsx version: 4.2.5.2
stringr version: 1.5.0
matrixStats version: 1.0.0
```

### Input(s):

* An `.xlsx excel samplesheet` created by UGPM, LaNSE, Cinvestav-IPN from a Synapt G2-Si Mass Spectrometer. Contact Emmanuel Castro-Rios (eriosc@cinvestav.mx) for more info.  

NAMING CONVENTION: filename should be CONDITION1_vs_CONDITION2.xlsx, because the condition names will be taken from the filename.  

Example contents  
```
sheet number or name: 1
Accession	Peptide count	Unique peptides	Confidence score	Anova (p)	nlog.Anova	q Value	Max fold change	Power	Highest mean condition	Lowest mean condition	Mass	Description	20220608_34_HDMSE_N_P1_R001	20220608_34_HDMSE_N_P1_R002	20220608_34_HDMSE_N_P1_R003	20220608_35_HDMSE_N_P2_R001
Q2M243;J3QKX2	5	1	27.3012	3.90E-08	7.40898498193687	3.45E-07	4.42850961640127	0.999999916484847	Normal	Osteoporosis	75867.8723	Coiled-coil domain-containing protein 27 OS=Homo sapiens OX=9606 GN=CCDC27 PE=1 SV=2	37894.2229766787	44809.8331347101	37940.595720904	61166.4163882289
...
```

* A `.csv samplesheet` describing sampleID_replicate and the condition.  
Example lines  
```
muestra	condition
20220608_34_HDMSE_N_P1_R001	Normal
20220608_34_HDMSE_N_P1_R002	Normal
20220608_34_HDMSE_N_P1_R003	Normal
20220608_44_HDMSE_OP_PI_R001	OP
20220608_44_HDMSE_OP_PI_R002	OP
20220608_44_HDMSE_OP_PI_R003	OP
...
```

### Outputs:

* A `.cleaned.xlsx excel samplesheet` with the processed data.  

Example contents  
```
sheet number or name: for volcano
Accession	Peptide.count	Unique.peptides	Anova..p.	Max.fold.change	Description	20220608_44_HDMSE_OP_PI_R001	20220608_44_HDMSE_OP_PI_R002	20220608_44_HDMSE_OP_PI_R003	20220608_45_HDMSE_OP_P2_R001	20220608_45_HDMSE_OP_P2_R002	20220608_45_HDMSE_OP_P2_R003	20220608_46_HDMSE_OP_P3_R001	20220608_46_HDMSE_OP_P3_R002	20220608_46_HDMSE_OP_P3_R003	20220608_47_HDMSE_OP_P4_R001	20220608_47_HDMSE_OP_P4_R002	20220608_47_HDMSE_OP_P4_R003	20220608_48_HDMSE_OP_P5_R001	20220608_48_HDMSE_OP_P5_R002	20220608_48_HDMSE_OP_P5_R003	average.cond1	log10.cond1	sd.cond1	CV.cond1	Count.cond1	20220608_34_HDMSE_N_P1_R001	20220608_34_HDMSE_N_P1_R002	20220608_34_HDMSE_N_P1_R003	20220608_35_HDMSE_N_P2_R001	20220608_35_HDMSE_N_P2_R002	20220608_35_HDMSE_N_P2_R003	20220608_36_HDMSE_N_P3_R001	20220608_36_HDMSE_NP_P3_R002	20220608_36_HDMSE_NP_P3_R003	20220608_37_HDMSE_N_P4_R001	20220608_37_HDMSE_N_P4_R002	20220608_37_HDMSE_N_P4_R003	20220608_38_HDMSE_N_P5_R001	20220608_38_HDMSE_N_P5_R002	20220608_38_HDMSE_N_P5_R003	average.cond2	log10.cond2	sd.cond2	CV.cond2	Count.cond2	nlog10.Anova	ratio	log2.Ratio	id.cond1	id.cond2
Q2M243;J3QKX2	5	1	3.89955471247205E-08	4.4285096164012696	Coiled-coil domain-containing protein 27 OS=Homo sapiens OX=9606 GN=CCDC27 PE=1 SV=2	2713.59869633698	3913.81993913804	3286.88471458258	44782.3111960669	36740.2066695109	44355.9642622341	2634.38537196349	4729.11316931672	4081.87075997921	15031.0978549603	14241.3056608753	8290.76271434224	6677.38268286047	8087.39912999333	6760.47312842438	13755.1050633723	4.13846391193898	15159.486180206	1.10209890148883	15	37894.2229766787	44809.8331347101	37940.595720904	61166.4163882289	82589.875882028	67262.9792808686	53072.3270544626	70468.5684378713	58824.8376386443	69715.707380473	49174.6568252449	70450.2925450023	61205.3050565332	75794.274942905	73349.3324517582	60914.6150477542	4.78472150401376	13801.5597539841	0.226572223154727	15	7.40898498193687	4.42850961640127	2.14682125164747	24	1
...
```

## Module parameters:

| --param | example  | description |
|:---------:|:--------:|:-------------------:|
| --input_dir | "test/data/" | directory with all .xlsx files from the experiment |
| --sample_sheet | "test/data/sample_sheet.csv" | comma separated file describing sampleID_replicate and the condition |

## Testing the module:

* Estimated test time:  **1 minute(s)**  

1. Test this module locally by running,
```
bash testmodule.sh
```

2.`[>>>] Module Test Successful` should be printed in the console.  

## module directory structure

````
.
├── main.nf                                 # Nextflow main script
├── readme.md                               # this readme
├── scripts -> ../../scripts/               # dir with all the scripts for the pipeline
├── test                                    # dir with test materials
│   └── data -> ../../../real-data/         # symlink to input data
│   └── results                            
│       └── 01-clean-file                                                                                                                                        
│           └── OP_vs_Normal.cleandata.xlsx # excel file after data wrangling
│           └── ...
├── testmodule.nf                           # Nextflow test script to call the main.nf after simulating channel interactions
└── testmodule.sh                           # bash script to test the whole module
````
## References
* The type of data used in this module was generated by eriosc@cinvestav.mx at CINVESTAV
