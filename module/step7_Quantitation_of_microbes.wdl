version development

workflow step7_Quantitation_of_microbes_pipeline {
	input {
		String Sample_Name
		Directory Script
		File Fasta_1
		File Fasta_2
		File Step6_result_id
		File Kraken_report
		File Mpa_report
	}

	call Quantitation_of_microbes {
		input:
			sample_name = Sample_Name,
			script = Script,
			fasta_1 = Fasta_1,
			fasta_2 = Fasta_2,
			step6_result_id = Step6_result_id,
			kraken_report = Kraken_report,
			mpa_report = Mpa_report
	}

	output {
		File count_file = Quantitation_of_microbes.count_file
		File barcode_file = Quantitation_of_microbes.barcode_file
	}
}

task Quantitation_of_microbes {
	meta {
		description: "Quantitation Of Microbes Analysis"
	}

	input {
		String sample_name
		Directory script
		File fasta_1
		File fasta_2
		File step6_result_id
		File kraken_report
		File mpa_report
	}

	String step7_outdir = "step7_Quantitation_of_microbes/~{sample_name}/result/"

	parameter_meta {
		sample_name: "Input the sample name"
		script: "Input the script directory"
		fasta_1: "Input the step 2 result fasta 1 file"
		fasta_2: "Input the step 2 result fasta 2 file"
		step6_result_id: "Input the step 6 step6.result.id file"
		kraken_report: "Input the step1 kraken.report.txt file"
		mpa_report: "Input the step1 kraken.report.mpa.txt file"
	}

	command <<<
		/usr/bin/Rscript ~{script}/functions/taxa_counts.r --sample_name ~{sample_name} --fa1 ~{fasta_1} --fa2 ~{fasta_2} --taxa ~{step6_result_id} --kraken_report ~{kraken_report} --mpa_report ~{mpa_report} --out_path ~{step7_outdir}
	>>>

	output {
		File barcode_file = "~{step7_outdir}/~{sample_name}.all.barcodes.txt"
		File count_file = "~{step7_outdir}/~{sample_name}.counts.txt"
	}

	runtime {
		cpu: 1
		memory: "8 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
