version development

workflow step4_Barcode_level_signal_denoising_pipeline {
	input {
		String Sample_Name
		File Kraken_Report
		File Sckmer
		Directory Script
	}

	call Barcode_level_signal_denoising {
		input:
			sample_name = Sample_Name,
			script = Script,
			sckmer = Sckmer,
			kraken_report = Kraken_Report
	}

	output {
		File step4_result = Barcode_level_signal_denoising.step4_result
		File step4_info = Barcode_level_signal_denoising.step4_info
	}
}

task Barcode_level_signal_denoising {
	meta {
		description: "Barcode Level Signal Denoising Analysis"
	}

	input {
		String sample_name
		Directory script
		File kraken_report
		File sckmer
	}

	String step4_outdir = "step4_Barcode_level_signal_denoising/~{sample_name}/result/"

	parameter_meta {
		sample_name: "Input the sample name"
		script: "Input the script directory"
		kraken_report: "Input the kraken.report.txt file"
		sckmer: "Input the sckmer.txt file"
	}

	command <<<
		mkdir -p ~{step4_outdir}
		/usr/bin/Rscript ~{script}/function/step4.R ~{kraken_report} ~{sckmer} ~{step4_outdir}
		echo -e "~{sample_name}\t~{step4_outdir}/step4.result" > ~{sample_name}.info.txt
	>>>

	output {
		File step4_result = "~{step4_outdir}/step4.result"
		File step4_info = "~{sample_name}.info.txt"
	}

	runtime {
		cpu: 1
		memory: "2 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
