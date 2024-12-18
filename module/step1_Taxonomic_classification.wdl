version development

workflow Taxonomic_classification_analysis {
	input {
		String Sample_Name
		File Fastq1
		File Fastq2
		Directory Script
		Directory Database
		Directory Software
	}

	call Taxonomic_classification {
		input:
			sample_name = Sample_Name,
			fastq1 = Fastq1,
			fastq2 = Fastq2,
			script = Script,
			database = Database,
			software = Software
	}
}

task Taxonomic_classification {
	meta {
		description: "Taxonomic Classification Analysis"
	}

	input {
		String sample_name
		File fastq1
		File fastq2
		Directory script
		Directory database
		Directory software
	}

	String outdir = "step1_Taxonomic_classification/~{sample_name}/result/"
	String kraken2 = "kraken2"

	parameter_meta {
		fastq1: "Input the fastq1.gz file"
		fastq2: "Input the fastq2.gz file"
		script: "Input the script directory"
		database: "Input the datbase directory"
		software: "Input the software directory"
	}

	command <<<
		mkdir -p ~{outdir}
		/usr/bin/Rscript ~{script}/functions/run_kraken.r --sample ~{sample_name} --fq1 ~{fastq1} --fq2 ~{fastq2} --out_path ~{outdir} --ncbi_blast_path ~{software}/blast-2.2.23/bin/ --Kraken2Uniq_path ~{kraken2} --kraken_database_path ~{database} --kreport2mpa_path ~{script}/functions/kreport2mpa.py  --paired T
		echo -e "~{sample_name}\t{outdir}/~{sample_name}.kraken.report.mpa.txt" > mpa_report_info.txt
		echo -e "~{sample_name}\t{outdir}/~{sample_name}.kraken.report.txt" > kraken_report_info.txt
	>>>

	output {
		File fq1 = "~{outdir}/~{sample_name}_1.fq"
		File fq2 = "~{outdir}/~{sample_name}_2.fq"
		File kraken_output = "~{outdir}/~{sample_name}.kraken.output.txt"
		File kraken_report_mpa = "~{outdir}/~{sample_name}.kraken.report.mpa.txt"
		File kraken_report_std = "~{outdir}/~{sample_name}.kraken.report.std.txt"
		File kraken_report = "~{outdir}/~{sample_name}.kraken.report.txt"
		File kraken_report_info = "kraken_report_info.txt"
		File mpa_report_info = "mpa_report_info.txt"
	}

	runtime {
		cpu: 2
		memory: "16 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
