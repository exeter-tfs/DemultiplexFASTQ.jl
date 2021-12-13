# DemultiplexFASTQ

Demultiplex FASTQ files in which the index read comprises `n`bp sample index and `m`bp random barcode/UMI.

## Installation
Install using julia package manager
```julia
    ] add https://github.com/exeter-tfs/DemultiplexFASTQ.jl
```


## Running
Make script in directory containing fastq file or wherever relevant with content:
```julia
using DemultiplexFASTQ
processargs()
````
This file is also given in `scripts` directory. Then run:
```
    julia demultiplex.jl -ignorelane -meta samplemeta.tsv -outfolder data -indexfile index.fq.gz reads.fq.gz
```

Use `-ignorelane` when samples are pooled over all lanes. Do not use if library pools differ between lanes such that the same index may be used different samples in different lanes, in this case ensure sample meta file contains a column specifying the lane as below.


### Example Sample Meta File
A delimited text file with required columns `SampleName` and `Index`, and optional columns `Lane` and `BarcodeLength` eg.

|  SampleName  | Index  | Lane  | BarcodeLength |
|--------------|--------|-------|---------------|
| Sample_A     | ATCACG |   1   |     6         |
| Sample_B     | TAGCTT |   1   |     8         |
| Sample_C     | AGTCAA |   2   |     6         |
| Sample_D     | GTGAAA |   2   |     6         |


```
SampleName  Index   Lane    BarcodeLength
Sample_A    ATCACG  1   6        
Sample_B    TAGCTT  1   8        
Sample_C    AGTCAA  2   6        
Sample_D    GTGAAA  2   6        

```
