version development

task File_Merge {
	meta {
		description: "file information merge"
	}

	input {
		Array[File] kraken_report_info
		Array[File] mpa_report_info
		Array[File] fasta1_info
		Array[File] fasta2_info
		Array[File] step4_info
	}

	parameter_meta {
		kraken_report_info: "Input the step1 kraken.report.txt file"
		mpa_report_info: "Input the step1 kraken.report.mpa.txt file"
		fasta1_info: "Input the step2 result fasta 1 file"
		fasta2_info: "Input the step2 result fasta 2 file"
		step4_info: "Input the step4 result merge"
	}

	command <<<
		cat ~{sep=" " kraken_report_info} > kraken_report.list.txt
		cat ~{sep=" " mpa_report_info} > mpa_report.list.txt
		cat ~{sep=" " fasta1_info} > fasta1_info.list.txt
		cat ~{sep=" " fasta2_info} > fasta2_info.list.txt
		cat ~{sep=" " step4_info} > step4_result.list.txt
	>>>

	output {
		Map[String, File] kraken_report_map = read_map("kraken_report.list.txt")
		Map[String, File] mpa_report_map = read_map("mpa_report.list.txt")
		Map[String, File] fasta1_map = read_map("fasta1_info.list.txt")
		Map[String, File] fasta2_map = read_map("fasta2_info.list.txt")
		Map[String, File] step4_result_map = read_map("step4_result.list.txt")
	}

	runtime {
		cpu: 1
		memory: "2 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
