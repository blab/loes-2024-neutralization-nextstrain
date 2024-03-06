rule download_loes_neutralization_data:
    output:
        data="loes_data/titers.csv",
    params:
        data_url="https://raw.githubusercontent.com/jbloomlab/flu_seqneut_DRIVE_2021-22_repeat_vax/main/results/aggregated_titers/titers.csv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        curl -L "{params.data_url}" -o "{output.data}"
        """

rule rename_strains_in_neutralization_data:
    input:
        data="loes_data/titers.csv",
        strain_name_mapping="loes-neutralization-models/build-configs/loes/strain_name_mapping.tsv",
    output:
        data="loes_data/titers_renamed.csv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk replace \
            -f "virus" \
            --keep-key \
            --kv-file {input.strain_name_mapping} \
            --pattern "(.+)" \
            --replacement '{{kv}}' \
            {input.data} > {output.data}
        """

rule get_strains_from_neutralization_data:
    input:
        data="loes_data/titers_renamed.csv",
    output:
        data="loes_data/strains.txt",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk cut \
            -f "virus" \
            {input.data} \
            | sed 1d \
            | sort -k 1,1 \
            | uniq > {output.data}
        """

rule convert_neutralization_data_into_initial_titers_format:
    input:
        data="loes_data/titers_renamed.csv",
    output:
        data="loes_data/initial_standard_titers.csv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk mutate -f serum -n individual -p '^(.+)d\d+' {input.data} \
            | csvtk mutate -f serum -n day_order -p '.+d(\d+)$' \
            | csvtk cut -f virus,titer,serum,individual,day_order \
            | csvtk rename -f virus,serum -n virus_strain,serum_id > {output.data}
        """

rule get_reference_strain_per_serum_id_by_max_titer:
    input:
        data="loes_data/initial_standard_titers.csv",
    output:
        data="loes_data/reference_strain.csv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk sort -k titer:nr {input.data} \
            | csvtk uniq -f serum_id -n 1 \
            | csvtk cut -f virus_strain,serum_id \
            | csvtk rename -f virus_strain -n serum_strain > {output.data}
        """

rule merge_titers_and_reference_strains_by_serum_id:
    input:
        data="loes_data/initial_standard_titers.csv",
        references="loes_data/reference_strain.csv",
    output:
        data="loes_data/standard_titers.tsv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk join -f serum_id {input.data} {input.references} \
            | csvtk mutate2 -n source -e '"Loes2024"' \
            | csvtk cut -T -f virus_strain,serum_strain,serum_id,source,titer,individual,day_order > {output.data}
        """

rule filter_titers_by_vaccination_status:
    input:
        data="loes_data/standard_titers.tsv",
    output:
        data="loes_data/standard_titers/{day_order}.tsv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk filter2 \
            -t \
            -f '$day_order=={wildcards.day_order}' \
            {input.data} > {output.data}
        """
