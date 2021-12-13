

function getlane(file)
    lane = match(r"L[0-9][0-9][0-9]", file)
    if isnothing(lane)
        return -1
    else
        return parse(Int, lane.match[2:end])
    end
end


function rundemultiplex(readfile, indexfile, metafile, outfolder, ignorelane=true, bl=6)
    
    println("[SFQ]\tignorelane         :\t", ignorelane)
    
    meta = CSV.File(metafile)
    indexes = meta.Index
    samples = meta.SampleName
    indexlength = maximum(length, indexes)

    if !all(indexlength .== length.(indexes))
        error("Not all indexes identical length: \nindexes:$indexes \nindexlengths: $(length.(indexes))")
    end
    
    if hasproperty(meta, :BarcodeLength)
        barcodelengths = meta.BarcodeLength
    else
        barcodelengths = fill(bl, length(indexes))
        println("[SFQ]\tBarcode lengths not specified, using $bl for all samples")
    end

    if !ignorelane && !hasproperty(meta, :Lane)
        println("[SFQ]\tWarning ignorelane=false and lane not set in metafile, ignoring lane")
        ignorelane = true
    end


    if ignorelane
        demultiplex(readfile, indexfile, indexes, samples, outfolder, barcodelengths, indexlength)
    else
        lane = getlane(readfile)
        ind = meta.Lane .== lane
        println("[SFQ]\tRestricting Lane   :\t", lane, " containing ", sum(ind), " samples, excluding ", sum(.!ind), " samples.")
        demultiplex(readfile, indexfile, indexes[ind], samples[ind], outfolder, barcodelengths[ind], indexlength)
    end
    
end


function demultiplex(readfile, indexfile, indexes, labels, folder, barcodelengths, il=6)
    
    println("[SFQ]\tSplitting Reads    :\t$readfile")
    println("[SFQ]\tSplitting Indexes  :\t$indexfile")
    println("[SFQ]\tIndexes            :\t$indexes")
    println("[SFQ]\tLabels             :\t$labels")
    println("[SFQ]\tBarcodeLengths     :\t$barcodelengths")
    println("[SFQ]\tFolder             :\t$folder")

    ### open files
    outdirs = joinpath.(folder, string.("Sample_", labels))
    for d in outdirs
        try
            mkpath(d)
        catch
        end
    end
     
    files   = joinpath.(outdirs, string.(labels, "_", indexes, "_", basename.(readfile)))

    
    um_file = joinpath(folder, "Sample_unmatched", "unmatched_index_"*basename(readfile))
    
    mkpath(dirname(um_file))
    files   = [files ; um_file]
    println("[SFQ]\tFiles            :\t$files")
    
 
    streams = GzipCompressorStream.(open.(files, "w"))
    index_dict = Dict(indexes[i] => i for i = 1:length(indexes))
    counts = zeros(Int, length(streams))
 
    rio = open(readfile)  |> GzipDecompressorStream
    iio = open(indexfile) |> GzipDecompressorStream

    total_reads = 0
    st = time()
    while !eof(rio) && !eof(iio) 
        read_id   = readline(rio)
        read_read = readline(rio)
        read_qid  = readline(rio)
        read_qs   = readline(rio)

        index_id   = readline(iio)
        index_read = readline(iio)
        index_qid  = readline(iio)
        index_qs   = readline(iio)

        index, barcode = index_read[1:il], index_read[(il+1):end]
        stream_index = get(index_dict, index, length(files))

        if stream_index < length(files)
            bl = barcodelengths[stream_index]
            barcode = barcode[1:bl] ## chop random barcode at specified length
        end

        ids = split(read_id)

        barcode_text = ifelse(isempty(barcode), "", string(":", barcode))

        println(streams[stream_index], ids[1], barcode_text, " ", ids[2], ":", index)
        println(streams[stream_index], read_read)
        println(streams[stream_index], read_qid)
        println(streams[stream_index], read_qs)
        
        counts[stream_index] += 1
        total_reads += 1
        
    end

    close(rio)
    close(iio)
    close.(streams)
    
    println("########################### Summary ###########################")
    println("File\tCount\tProportion")
    s = sum(counts)
    for (f, c) in zip(files, counts)
        println(f, "\t", c, "\t", c/s)
    end
    println("###############################################################")

    println("[SFQ]\tTotal Reads    :\t", total_reads)
    println("[SFQ]\tComplete in    :\t", time() - st, " seconds.")
end
