# DemultiplexFASTQ

Demultiplex FASTQ files in which the index read comprises `n`bp sample index and `m`bp random barcode/UMI.

## Installation
Install using julia package manager
```julia
    ] add https://github.com/exeter-tfs/DemultiplexFASTQ.jl
```


## Running
```
    julia -e "using DemultiplexFASTQ; processargs()" -ignorelane -meta samplemeta.tsv -outfolder data -indexfile index.gq.gz reads.fq.gz
```
