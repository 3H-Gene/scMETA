version development

workflow step5_Sample_level_signal_denoising_pipeline {
	input {
		Array[File] Kraken_Report
		Directory Script
	}

	call Sample_level_signal_denoising {
		input:
			kraken_report = Kraken_Report,
			script = Script
	}

	output {
		File step5_c2 = Sample_level_signal_denoising.step5_c2
		File step5_kr = Sample_level_signal_denoising.step5_kr
		File step5_result = Sample_level_signal_denoising.step5_result
	}
}

task Sample_level_signal_denoising {
	meta {
		description: "Sample Level Signal Denoising Analysis"
	}

	input {
		Array[File] kraken_report
		Directory script
	}

	String step5_outdir = "step5_Sample_level_signal_denoising/result"

	parameter_meta {
		kraken_report: "Input the kraken.report.txt file list"
		script: "Input the script directory"
	}

	command <<<
		mkdir -p ~{step5_outdir}
		cat ~{sep=' ' kraken_report} > list
		/usr/bin/perl ~{script}/functions/make.list.pl list ./
		/usr/bin/Rscript ~{script}/functions/read_kraken_reports.r list.1 ~{step5_outdir} GA
	>>>

	output {
		File step5_c2 = "~{step5_outdir}/step5.c2.result"
		File step5_kr = "~{step5_outdir}/step5.kr.result"
		File step5_result = "~{step5_outdir}/step5.result"
	}

	runtime {
		cpu: 1
		memory: "2 GB"
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
	}
}
