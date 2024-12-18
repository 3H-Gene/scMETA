version development

import "module/Sample_List.wdl" as Sample_List
import "module/Unpack.wdl" as Unpack
import "module/File_Merge.wdl" as File_Merge
import "module/step1_Taxonomic_classification.wdl" as Taxonomic_classification
import "module/step2_Extract_microbiome_reads.wdl" as Extract_microbiome_reads
import "module/step3_Single-cell_k-mer_analysis.wdl" as Singlecell_kmer_analysis
import "module/step4_Barcode_level_signal_denoising.wdl" as Barcode_level_signal_denoising
import "module/step5_Sample_level_signal_denoising.wdl" as Sample_level_signal_denoising
import "module/step6_Identifying_contaminants_FP.wdl" as Identifying_contaminants_FP
import "module/step7_Quantitation_of_microbes.wdl" as Quantitation_of_microbes

workflow scMeta_analysis {
	input {
		File Fastq1_file
		File Fastq2_file
		Map[String, File] Fastq1_Data = read_map(Fastq1_file)
		Map[String, File] Fastq2_Data = read_map(Fastq2_file)
		File Script
		File Database
		File Software
	}

	## unpack the file
	call Unpack.Unpack_File as Unpack {
		input:
			script = Script,
			database = Database,
			software = Software
	}

	## Get the sample list
	call Sample_List.Get_Sample_List as Get_Sample_List {
		input:
			fastq1_data = Fastq1_Data
	}

	## analysis for every sample
	scatter (item in Get_Sample_List.Sample_List) {
		String Sample = "~{item}"
		File Fastq1 = Fastq1_Data["~{item}"]
		File Fastq2 = Fastq2_Data["~{item}"]

		## step 1 analysis
		call Taxonomic_classification.Taxonomic_classification as Taxonomic_classification {
			input:
				sample_name = Sample,
				fastq1 = Fastq1,
				fastq2 = Fastq2,
				script = Unpack.script,
				database = Unpack.database,
				software = Unpack.software
		}

		## step 2 analysis
		call Extract_microbiome_reads.Extract_microbiome_reads as Extract_microbiome_reads {
			input:
				sample_name = Sample,
				fq1 = Taxonomic_classification.fq1,
				fq2 = Taxonomic_classification.fq2,
				kraken_report = Taxonomic_classification.kraken_report,
				kraken_output = Taxonomic_classification.kraken_output,
				mpa_report = Taxonomic_classification.kraken_report_mpa,
				script = Unpack.script
		}

		## step 3 analysis
		call Singlecell_kmer_analysis.Singlecell_kmer_analysis as Singlecell_kmer_analysis {
			input:
				sample_name = Sample,
				fa_1 = Extract_microbiome_reads.fa_1,
				fa_2 = Extract_microbiome_reads.fa_2,
				microbiome_output = Extract_microbiome_reads.microbiome_output,
				kraken_report = Taxonomic_classification.kraken_report,
				mpa_report = Taxonomic_classification.kraken_report_mpa,
				script = Unpack.script
		}

		## step 4 analysis
		call Barcode_level_signal_denoising.Barcode_level_signal_denoising as Barcode_level_signal_denoising {
			input:
				sample_name = Sample,
				script = Unpack.script,
				sckmer = Singlecell_kmer_analysis.sckmer,
				kraken_report = Taxonomic_classification.kraken_report
		}
	}

	## step 5 analysis
	call Sample_level_signal_denoising.Sample_level_signal_denoising as Sample_level_signal_denoising {
		input:
			kraken_report = Taxonomic_classification.kraken_report,
			script = Unpack.script
	}

	## File_Merge
	call File_Merge.File_Merge as File_Merge {
		input:
			kraken_report_info = Taxonomic_classification.kraken_report_info,
			mpa_report_info = Taxonomic_classification.mpa_report_info,
			fasta1_info = Extract_microbiome_reads.fasta1_info,
			fasta2_info = Extract_microbiome_reads.fasta2_info,
			step4_info = Barcode_level_signal_denoising.step4_info
	}

	scatter (item in Get_Sample_List.Sample_List) {
		## step 6 analysis
		call Identifying_contaminants_FP.Identifying_contaminants_FP as Identifying_contaminants_FP {
			input:
				sample_name = "~{item}",
				script = Unpack.script,
				step5_kr = Sample_level_signal_denoising.step5_kr,
				step5_c2 = Sample_level_signal_denoising.step5_c2,
				step4_result = File_Merge.step4_result_map["~{item}"]
		}

		## step 7 analysis
		call Quantitation_of_microbes.Quantitation_of_microbes as Quantitation_of_microbes {
			input:
				sample_name = "~{item}",
				script = Unpack.script,
				fasta_1 = File_Merge.fasta1_map["~{item}"],
				fasta_2 = File_Merge.fasta2_map["~{item}"],
				step6_result_id = Identifying_contaminants_FP.step6_result_id,
				kraken_report = File_Merge.kraken_report_map["~{item}"],
				mpa_report = File_Merge.mpa_report_map["~{item}"]
		}
	}

	output {
		## step 1 result
		Array[File] all_fq1_output = Taxonomic_classification.fq1
		Array[File] all_fq2_output = Taxonomic_classification.fq2
		Array[File] all_kraken_output = Taxonomic_classification.kraken_output
		Array[File] all_kraken_report_mpa = Taxonomic_classification.kraken_report_mpa
		Array[File] all_kraken_report_std = Taxonomic_classification.kraken_report_std
		Array[File] all_kraken_report = Taxonomic_classification.kraken_report

		## step 2 result
		Array[File] all_fa_1 = Extract_microbiome_reads.fa_1
		Array[File] all_fa_2 = Extract_microbiome_reads.fa_2
		Array[File] all_microbiome_output = Extract_microbiome_reads.microbiome_output

		## step 3 result
		Array[File] all_sckmer = Singlecell_kmer_analysis.sckmer

		## step 4 reuslt
		Array[File] all_step4_result = Barcode_level_signal_denoising.step4_result

		## step 5 result
		File step5_c2 = Sample_level_signal_denoising.step5_c2
		File step5_kr = Sample_level_signal_denoising.step5_kr
		File step5_result = Sample_level_signal_denoising.step5_result

		## step 6 result
		Array[File] all_step6_result = Identifying_contaminants_FP.step6_result
		Array[File] all_step6_result_id = Identifying_contaminants_FP.step6_result_id

		## step 7 result
		Array[File] all_barcode_file = Quantitation_of_microbes.barcode_file
		Array[File] all_count_file = Quantitation_of_microbes.count_file
	}
}
