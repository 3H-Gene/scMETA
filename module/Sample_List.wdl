version development

task Get_Sample_List {
	meta {
		description: "Get the Sample List"
	}

	input {
		Map[String, File] fastq1_data
	}

	parameter_meta {
		fastq1_data: "fastq1 information data, information like sample_name\tfq1.gz"
	}

	command <<<
		cut -f 1 ~{write_map(fastq1_data)}
	>>>

	output {
		Array[String] Sample_List = read_lines(stdout())
	}

	runtime {
		cpu: 1
		memory: "2 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
