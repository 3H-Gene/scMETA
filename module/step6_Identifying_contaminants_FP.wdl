version development

workflow step6_Identifying_contaminants_FP_pipeline {
	input {
		File Sample_Name
		Directory Script
		File Step5_kr
		File Step5_c2
		File Step4_result
	}

	call Identifying_contaminants_FP {
		input:
			sample_name = Sample_Name,
			script = Script,
			step5_kr = Step5_kr,
			step5_c2 = Step5_c2,
			step4_result = Step4_result
	}

	output {
		File step6_result_id = Identifying_contaminants_FP.step6_result_id
		File step6_result = Identifying_contaminants_FP.step6_result
	}
}

task Identifying_contaminants_FP {
	meta {
		description: "Identifying contaminants FP Analysis"
	}

	input {
		String sample_name
		Directory script
		File step5_kr
		File step5_c2
		File step4_result
	}

	parameter_meta {
		sample_name: "Input the sample name"
		script: "Input the script directory"
		step5_kr: "Input the step5.kr.result file"
		step5_c2: "Input the step5.c2.result file"
		step4_result: "Input the step4.result file"
	}

	String step6_outdir = "step6_Identifying_contaminants_FP/~{sample_name}/result/"

	command <<<
		mkdir -p ~{step6_outdir}
		/usr/bin/Rscript ~{script}/functions/step6.r ~{step4_result} ~{step5_c2} ~{step6_outdir} ~{step5_kr} ~{script}/GA_meta_1/cell.lines.txt
		cat ~{step6_outdir}/step6.result | cut -f 1 | grep -v taxid > ~{step6_outdir}/step6.result.id
	>>>

	output {
		File step6_result = "~{step6_outdir}/step6.result"
		File step6_result_id = "~{step6_outdir}/step6.result.id"
	}

	runtime {
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
		cpu: 1
		memory: "4 GB"
	}
}
