# Multi-condition-analysis-1
**Author(s):**

* Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
* Adriana Becerra Cervera (abecerra@inmegen.edu.mx)   
* Diana Ivette Aparicio Bautista (daparicio@inmegen.gob.mx)   
* Rafael Velazquez Cruz (rvelazquez@inmegen.gob.mx)

**Date:** September 2023  

---

## Module description:  

A (DSL2) Nextflow module to replicate PLSDA and venn diagrams from DEP data

## Module Dependencies:
| Requirement | Version  | Required Commands |
|:---------:|:--------:|:-------------------:|
| [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) | 22.10.4 | nextflow |
| [R](https://www.r-project.org/) | 4.2.2 | Rscript |

# R packages required:

```
cowplot version: 1.1.1
openxlsx version: 4.2.5.2
tidyr version: 1.3.0
ggsci version: 3.0.0
scales version: 1.2.1
stringr version: 1.5.0
dplyr version: 1.1.2
factoextra version: 1.0.7
ggplot2 version: 3.4.2
ggvenn version: 0.1.10
ropls version: 1.32.0
scatterplot3d version: 0.3-44 
purrr version: 1.0.1

```

### Input(s):

* A ` "Total_protein_PLSDA-PCA.xlsx", excel file` that includes all of the detected proteins in the evaluated conditions, in table format.  

Example contents  
```
sample_id       condicion       P04217  P01023  Q8WWZ7  Q09428
20220608_34_HDMSE_N_P1_R001     N       36353.52363     50338.57254     0       0
20220608_34_HDMSE_N_P1_R002     N       41329.12922     52938.46197     17.76093614     0
20220608_34_HDMSE_N_P1_R003     N       38530.74795     49830.05592     0       1.475326865
20220608_36_HDMSE_N_P3_R001     N       27093.23423     45550.87057     109.1547172     4.376165809
20220608_36_HDMSE_N_P3_R002     N       26938.02884     44113.33152     42.30108357     16.80307341
20220608_36_HDMSE_N_P3_R003     N       25023.78261     45638.40939     75.33983583     12.10888364
20220608_37_HDMSE_N_P4_R001     N       45232.14913     57859.06924     57.86140548     1246.738609	
...
```

* All of the `.UP_and_DOWN_hits.xlsx excel file` that includes only UP and DOWN differentiated peptides from the previous module. 

Example contents  
```
sheet number or name: Up_proteins
singleID	Accession	Peptide.count	Unique.peptides	Anova..p.	Max.fold.change	Description	20220608_49_HDMSE_OPI_P1_R001	20220608_49_HDMSE_OPI_P1_R002	20220608_49_HDMSE_OPI_P1_R003	20220608_50_HDMSE_OPI_P2_R001	20220608_50_HDMSE_OPI_P2_R002	20220608_50_HDMSE_OPI_P2_R003	20220608_51_HDMSE_OPI_P3_R001	20220608_51_HDMSE_OPI_P3_R002	20220608_51_HDMSE_OPI_P3_R003	20220608_52_HDMSE_OPI_P4_R001	20220608_52_HDMSE_OPI_P4_R002	20220608_52_HDMSE_OPI_P4_R003	20220608_53_HDMSE_OPI_P5_R001	20220608_53_HDMSE_OPI_P5_R002	20220608_53_HDMSE_OPI_P5_R003	average.cond1	log10.cond1	sd.cond1	CV.cond1	Count.cond1	20220608_34_HDMSE_N_P1_R001	20220608_34_HDMSE_N_P1_R002	20220608_34_HDMSE_N_P1_R003	20220608_35_HDMSE_N_P2_R001	20220608_35_HDMSE_N_P2_R002	20220608_35_HDMSE_N_P2_R003	20220608_36_HDMSE_N_P3_R001	20220608_36_HDMSE_NP_P3_R002	20220608_36_HDMSE_NP_P3_R003	20220608_37_HDMSE_N_P4_R001	20220608_37_HDMSE_N_P4_R002	20220608_37_HDMSE_N_P4_R003	20220608_38_HDMSE_N_P5_R001	20220608_38_HDMSE_N_P5_R002	20220608_38_HDMSE_N_P5_R003	average.cond2	log10.cond2	sd.cond2	CV.cond2	Count.cond2	nlog10.Anova	ratio	log2.Ratio	id.cond1	id.cond2
P02652	P02652;V9GYM3;V9GYE3;V9GYG9;V9GYC1;V9GYS1	35	16	1.10205178316392E-11	5.8097249695031596	Apolipoprotein A-II OS=Homo sapiens OX=9606 GN=APOA2 PE=1 SV=1	1560.51989553997	2038.55310749808	1657.10384214502	1380.10937312234	1502.95280865761	1860.9161024207	6534.98083126715	6437.01598905769	6789.24523084373	816.224260914083	1024.33175889741	918.336856471964	2044.24497790374	1925.8979410283	2070.44521504447	2570.72521272082	3.41005565697078	2117.99525033456	0.823890176925174	15	15243.4765332117	12876.3041482122	13664.7020568282	21105.5418201246	16842.5961536651	19901.8796791473	13052.1116196771	14295.3171114888	13962.2355928701	12455.1376446641	12382.7689103517	11551.2920969297	15829.3175956577	16138.9410269904	14726.474881313	14935.2064580754	4.17421123048773	2720.79321323815	0.182173123677645	15	10.9577979983935	5.80972496950316	2.53846986853074	88	22
...
```

### Outputs:

* A `VENN_shared.png figure` with the figure showing the intersection for detected proteins in each condition.  

* A `VENN_shared_DEP_DOWN.png figure` with the figure showing the intersection for DOWN-expressed proteins in each condition.  

* A `VENN_shared_DEP_UP.png figure` with the figure showing the intersection for UP-expressed proteins in each condition.  

* A `PLS-DA.png figure` with the figure showing 3D rendering of the PLS coordinates for the 3 first components, using all of the sampels for all of the conditions.  

## Module parameters:


| --param | example  | description |
|:---------:|:--------:|:-------------------:|
| --intermediate_file1 | "test/data/Total_protein_PLSDA-PCA.xlsx" | excel file pre-build by hand that includes all detected proteins in all samples, in wide format |

## Testing the module:

* Estimated test time:  **1 minute(s)**  

1. Test this module locally by running,
```
bash testmodule.sh
```

2.`[>>>] Module Test Successful` should be printed in the console.  

## module directory structure

````
TO-DO
````
## References
* TO-DO: add a link to UGPM services that produce this kind of data