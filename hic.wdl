
#QUESTIONS:

#1. Why are not we providing paths to FASTQ files?
#2. 

workflow hic {
    # inputs definition
	String? "site"
	String? "genomeId"
	String? "stage"
	String? "ligation"
	String? "read1str"
	String? "read2str"

    # determine input files, etc.
	call inputs {
		input :
			fastqs = fastqs,
			bams = bams,
			nodup_bams = nodup_bams,
	}

	if (inputs.stage=='alignonly') {
		call alignonly {
			input:
				fastqs = fastqs,
				genome_id = genome_id,
				site= site,
				... 
		
		}
	}
	if (inputs.stage=='mergeonly') {

	}
	if (inputs.stage=='deduponly') {

	}
}



# stops after alignment and chimera handling
task alignonly {
    String? genome_id # reference genome
	String? site # reference genome
	String? read1str
	String? read2str 
    Array[File] fastqs 	# [end_id]

    # resource
	Int? cpu
	Int? mem_mb
    
    command {
		${"genomePath " + select_first([genome_id,"hg19"])} \
		${"site" + select_first([site,"MboI"])} \
		${"read1str" + select_first([read1str,"_R1"])} \
		${"read2str" + select_first([read2str,"_R1"])}
	}
	output {		
        File bam = glob("*.bam")[0]
		File bai = glob("*.bai")[0]
		File align_log = glob("*.align.log")[0]
		File flagstat_qc = glob("*.flagstat.qc")[0]
	}
	runtime {
		docker: 'aidenlab/juicer:latest'
	}
}

#starts after aligning, stops after merging files
task mergeonly {
    command {
		
	}
	output {		

	}
	runtime {

	}
}

#starts after merging, stops after deduping
task deduponly {
    command {
		
	}
	output {		

	}
	runtime {

	}
}

#starts after dedupping, finishes (is that the .hic file creation?)
task final {

}

# starts after hic file creation, only postprocesing?
task postproc {

}

# workflow system tasks
# here we have to dig out FASTQs names for the align task

task inputs {	# determine input type	
	# parameters from workflow
	Array[Array[Array[String]]] fastqs 
	Array[String] bams
	Array[String] merged_bams
	Array[String] dedupped_bams
	Array[String] hics

	command <<<
		python <<CODE
		name = ['fastq','bam','nodup_bam','ta','peak']
		arr = [${length(fastqs)},${length(bams)},
		       ${length(nodup_bams)},${length(tas)},
		       ${length(peaks)}]
		num_rep = max(arr)
		type = name[arr.index(num_rep)]
		with open('num_rep.txt','w') as fp:
		    fp.write(str(num_rep)) 
		with open('type.txt','w') as fp:
		    fp.write(type)		    
		CODE
	>>>
	output {
		String type = read_string("type.txt")
		Int num_rep = read_int("num_rep.txt")
	}