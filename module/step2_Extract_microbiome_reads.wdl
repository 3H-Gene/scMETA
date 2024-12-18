version development

workflow step2_Extract_microbiome_reads_pipeline {
	input {
		String Sample_Name
		File Fq1
		File Fq2
		File Kraken_Report
		File Kraken_Output
		File Mpa_Report
		Directory Script
	}

	call Extract_microbiome_reads {
		input:
			sample_name = Sample_Name,
			fq1 = Fq1,
			fq2 = Fq2,
			kraken_report = Kraken_Report,
			kraken_output = Kraken_Output,
			mpa_report = Mpa_Report,
			script = Script
	}

	output {
		File Fa_1 = Extract_microbiome_reads.fa_1
		File Fa_2 = Extract_microbiome_reads.fa_2
		File Microbiome_output = Extract_microbiome_reads.microbiome_output
	}
}

task Extract_microbiome_reads {
	meta {
		description: "Extract Microbiome Reads Analysis"
	}

	input {
		String sample_name
		File fq1
		File fq2
		File kraken_report
		File kraken_output
		File mpa_report
		Directory script
	}

	String fq1_outdir = "step2_Extract_microbiome_reads/~{sample_name}/result_fq1"
	String fq2_outdir = "step2_Extract_microbiome_reads/~{sample_name}/result_fq2"
	String step2_outdir = "step2_Extract_microbiome_reads/~{sample_name}/result"

	parameter_meta {
		sample_name: "Input the sample name"
		fq1: "Input the step1 fq1 file"
		fq2: "Input the step1 fq2 file"
		kraken_output: "Input the kraken.output.txt"
		kraken_report: "Input the kraken.report.txt"
		mpa_report: "kraken.report.mpa.txt"
		script: "Input the script directory"
	}

	command <<<
		mkdir -p ~{fq1_outdir}
		mkdir -p ~{fq2_outdir}
		mkdir -p ~{step2_outdir}
		/usr/bin/Rscript ~{script}/function/extract_microbiome_reads.r --sample_name ~{sample_name} --fq ~{fq1} --kraken_report ~{kraken_report} --mpa_report ~{mpa_report} --out_path ~{fq1_outdir}
		echo -e "~{sample_name}\t~{fq1_outdir}/~{sample_name}.fa" > fasta_1.txt
		/usr/bin/Rscript ~{script}/function/extract_microbiome_reads.r --sample_name ~{sample_name} --fq ~{fq2} --kraken_report ~{kraken_report} --mpa_report ~{mpa_report} --out_path ~{fq2_outdir}
		echo -e "~{sample_name}\t~{fq2_outdir}/~{sample_name}.fa" > fasta_2.txt
		/usr/bin/Rscript ~{script}/functions/extract_microbiome_output.r --sample_name ~{sample_name} --output_file ~{kraken_output} --kraken_report ~{kraken_report} --mpa_report ~{mpa_report} --out_path ~{step2_outdir}
	>>>

	output {
		File fa_1 = "~{fq1_outdir}/~{sample_name}.fa"
		File fa_2 = "~{fq2_outdir}/~{sample_name}.fa"
		File microbiome_output = "~{step2_outdir}/~{sample_name}.microbiome.output.txt"
		File fasta1_info = "fasta_1.txt"
		File fasta2_info = "fasta_2.txt"
	}

	runtime {
		cpu: 1
		memory: "8 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
