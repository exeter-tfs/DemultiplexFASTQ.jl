function processargs(ARGS)

    if length(ARGS) >= 3

        ignorelane = false
        indexfile = ""
        metafile = ""
        outfolder = ""
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
            elseif ARGS[index] == "-folder"
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
    
        println("Usage: splitfastq.jl [-ignorelane] [-indexfile <index_file>] -meta <meta> -outfolder <outfolder> ")
    end

end