# UPandDOWN-PCA
**Author(s):**

* Israel Aguilar-Ordoñez (iaguilaror@gmail.com)

**Date:** June 2023  

---

## Module description:  

A (DSL2) Nextflow module to calculate and plot PCA coordinates

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
```

### Input(s):

* A `.UP_and_DOWN_hits.xlsx excel file` that includes only UP and DOWN differentiated peptides from the previous module.  

Example contents  
```
sheet number or name: Up_proteins
singleID	Accession	Peptide.count	Unique.peptides	Anova..p.	Max.fold.change	Description	20220608_49_HDMSE_OPI_P1_R001	20220608_49_HDMSE_OPI_P1_R002	20220608_49_HDMSE_OPI_P1_R003	20220608_50_HDMSE_OPI_P2_R001	20220608_50_HDMSE_OPI_P2_R002	20220608_50_HDMSE_OPI_P2_R003	20220608_51_HDMSE_OPI_P3_R001	20220608_51_HDMSE_OPI_P3_R002	20220608_51_HDMSE_OPI_P3_R003	20220608_52_HDMSE_OPI_P4_R001	20220608_52_HDMSE_OPI_P4_R002	20220608_52_HDMSE_OPI_P4_R003	20220608_53_HDMSE_OPI_P5_R001	20220608_53_HDMSE_OPI_P5_R002	20220608_53_HDMSE_OPI_P5_R003	average.cond1	log10.cond1	sd.cond1	CV.cond1	Count.cond1	20220608_34_HDMSE_N_P1_R001	20220608_34_HDMSE_N_P1_R002	20220608_34_HDMSE_N_P1_R003	20220608_35_HDMSE_N_P2_R001	20220608_35_HDMSE_N_P2_R002	20220608_35_HDMSE_N_P2_R003	20220608_36_HDMSE_N_P3_R001	20220608_36_HDMSE_NP_P3_R002	20220608_36_HDMSE_NP_P3_R003	20220608_37_HDMSE_N_P4_R001	20220608_37_HDMSE_N_P4_R002	20220608_37_HDMSE_N_P4_R003	20220608_38_HDMSE_N_P5_R001	20220608_38_HDMSE_N_P5_R002	20220608_38_HDMSE_N_P5_R003	average.cond2	log10.cond2	sd.cond2	CV.cond2	Count.cond2	nlog10.Anova	ratio	log2.Ratio	id.cond1	id.cond2
P02652	P02652;V9GYM3;V9GYE3;V9GYG9;V9GYC1;V9GYS1	35	16	1.10205178316392E-11	5.8097249695031596	Apolipoprotein A-II OS=Homo sapiens OX=9606 GN=APOA2 PE=1 SV=1	1560.51989553997	2038.55310749808	1657.10384214502	1380.10937312234	1502.95280865761	1860.9161024207	6534.98083126715	6437.01598905769	6789.24523084373	816.224260914083	1024.33175889741	918.336856471964	2044.24497790374	1925.8979410283	2070.44521504447	2570.72521272082	3.41005565697078	2117.99525033456	0.823890176925174	15	15243.4765332117	12876.3041482122	13664.7020568282	21105.5418201246	16842.5961536651	19901.8796791473	13052.1116196771	14295.3171114888	13962.2355928701	12455.1376446641	12382.7689103517	11551.2920969297	15829.3175956577	16138.9410269904	14726.474881313	14935.2064580754	4.17421123048773	2720.79321323815	0.182173123677645	15	10.9577979983935	5.80972496950316	2.53846986853074	88	22
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

* A `.PCA_main.png figure` with the figure showing a PCA for two conditions.  

* A `PCA_diagnostic.png image` same as above but showing a panel with: screeplot, labeled PCA, a Parallel Coordinate Plot, and a biplot. Meant to provide an overview of the whole PCA.  

## Module parameters:

| --param | example  | description |
|:---------:|:--------:|:-------------------:|
| --sample_sheet | "../../real-data/sample_sheet.csv" | comma separated file describing sampleID_replicate and the condition |

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
│   └── data -> ../../02-volcano/test/results/02-volcano         # symlink to input data
│   └── results                            
│       └── 03-pca/
│           ├── OP_vs_Normal.cleandata.UP_and_DOWN_hits.PCA_diagnostic.png    # A panel plot with screeplot, Parallel Coordinate Plot, text=labeled PC1 vs PC2, and biplot for PC1 vs PC2  
│           ├── OP_vs_Normal.cleandata.UP_and_DOWN_hits.PCA_main.png          # A figure for PC1 vs PC2  
│           └── ...
├── testmodule.nf                           # Nextflow test script to call the main.nf after simulating channel interactions
└── testmodule.sh                           # bash script to test the whole module
````
## References
* Wickham H, Averick M, Bryan J, Chang W, McGowan LD, François R, Grolemund G, Hayes A, Henry L, Hester J, Kuhn M, Pedersen TL, Miller E, Bache SM, Müller K, Ooms J, Robinson D, Seidel DP, Spinu V, Takahashi K, Vaughan D, Wilke C, Woo K, Yutani H (2019). “Welcome to the tidyverse.” Journal of Open Source Software, 4(43), 1686. doi:10.21105/joss.01686.   
* Kassambara, A. and Mundt, F. (2020) Factoextra: Extract and Visualize the Results of Multivariate Data Analyses. R Package Version 1.0.7.
https://CRAN.R-project.org/package=factoextra   
