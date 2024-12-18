version development

workflow step3_Singlecell_kmer_analysis_pipeline {
	input {
		String Sample_Name
		File Fa_1
		File Fa_2
		File Microbiome_Output
		File Kraken_Report
		File Mpa_Report
		Directory Script
	}

	call Singlecell_kmer_analysis {
		input:
			sample_name = Sample_Name,
			fa_1 = Fa_1,
			fa_2 = Fa_2,
			microbiome_output = Microbiome_Output,
			kraken_report = Kraken_Report,
			mpa_report = Mpa_Report,
			script = Script
	}

	output {
		File sckmer_output = Singlecell_kmer_analysis.sckmer
	}
}

task Singlecell_kmer_analysis {
	meta {
		description: "Single-cell K-mer Analysis"
	}

	input {
		String sample_name
		File fa_1
		File fa_2
		File microbiome_output
		File kraken_report
		File mpa_report
		Directory script
	}

	parameter_meta {
		sample_name: "Input the sample name"
		fa_1: "Input the step2 fasta 1 file"
		fa_2: "Input the step2 fasta 2 file"
		microbiome_output: "Innput the step2 output file"
		kraken_report: "Input the step1 kraken.report.txt file"
		mpa_report: "Input the step1 kraken.report.mpa.txt file"
		script: "Input the script directory"
	}

	String step3_outdir = "step3_Single-cell_k-mer_analysis/~{sample_name}/result/"

	command <<<
		/usr/bin/Rscript ~{script}/functions/sckmer.r --sample_name ~{sample_name} --fa1 ~{fa_1} --fa2 ~{fa_2} --microbiome_output_file ~{microbiome_output} --kraken_report ~{kraken_report} --mpa_report ~{mpa_report} --out_path ~{step3_outdir}
	>>>

	output {
		File sckmer = "~{step3_outdir}/~{sample_name}.sckmer.txt"
	}

	runtime {
		cpu: 2
		memory: "16 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
