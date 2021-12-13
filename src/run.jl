
function julia_main()::Cint
    try
        processargs()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

function processargs()

    if length(ARGS) >= 3

        ignorelane = false
        indexfile = ""
        metafile = ""
        outfolder = "."
        index = 1
        readfile = ""
        while index <= length(ARGS)
            if ARGS[index] == "-ignorelane"
                ignorelane = true
            elseif ARGS[index] == "-indexfile"
                index += 1
                indexfile = ARGS[index]
            elseif ARGS[index] == "-meta"
                index += 1
                metafile = ARGS[index]
            elseif ARGS[index] == "-outfolder"
                index += 1
                outfolder = ARGS[index]
            else
                readfile = ARGS[index]
            end
            index += 1
        end
        rundemultiplex(readfile, indexfile, metafile, outfolder, ignorelane)
        # if index_file == ""
        #     split_fastq(file, meta, folder, ignore_lane)
        # else
        #     split_fastq_annot(file, index_file, meta, folder, ignore_lane)
        # end
            
    else
    
        println("Usage: DemultiplexFASTQ [-ignorelane] -meta <meta> -outfolder <outfolder> -indexfile <index_file> <fastqfile>")
        printboldln("\t-ignorelane\tSet if all lanes contain same pool of barcodes, note sample meta file must contain column *Lane* if *ignorelane* not set")
        printboldln("\t-meta\t\tSample meta file, a delimited file containing columns: *SampleName*, *Index*, *[Lane]*")
        printboldln("\t-outfolder\tOutput folder")
        printboldln("\t-indexfile\tFASTQ file containing index read")
    end

end

function printboldln(s)
    f = split(s, "*")
    for i = 1:2:length(f)
        print(f[i])
        (i < length(f)) && printstyled(f[i+1], bold=true)
    end
    println("")
end