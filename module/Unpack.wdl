version development

workflow Unpack_File {
	input {
		File script
		File database
		File software
	}

	call unpack as unpack_script {
		input:
			in = script
	}

	call unpack as unpack_database {
		input:
			in = database
	}

	call unpack as unpack_software {
		input:
			in = software
	}

	output {
		Directory script = unpack_script.outdir
		Directory database = unpack_database.outdir
		Directory software = unpack_software.outdir
	}
}

task unpack {
	meta {
		description: "unpack the tar file"
	}

	input {
		File in
	}

	parameter_meta {
		in: "Input the pack file to unpack"
	}

	String dir = basename(in, 'tar.gz')

	command <<<
		tar zxf ~{in}
	>>>

	output {
		Directory outdir = "~{dir}"
	}

	runtime {
		cpu: 1
		docker: "ccr.ccs.tencentyun.com/ll-test/sahmi"
		memory: "2 GB"
	}
}
