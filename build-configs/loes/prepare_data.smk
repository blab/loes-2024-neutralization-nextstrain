rule rename_strains_in_neutralization_data:
    input:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals.csv",
        strain_name_mapping="loes-neutralization-models/build-configs/loes/strain_name_mapping.tsv",
    output:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_renamed.csv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk replace \
            -f "strain" \
            --keep-key \
            --kv-file {input.strain_name_mapping} \
            --pattern "(.+)" \
            --replacement '{{kv}}' \
            {input.data} \
            | csvtk cut -f 2- > {output.data}
        """

rule get_strains_from_neutralization_data:
    input:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_renamed.csv",
    output:
        data="loes-neutralization-models/build-configs/loes/strains.txt",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk cut \
            -f "strain" \
            {input.data} \
            | sed 1d \
            | sort -k 1,1 \
            | uniq > {output.data}
        """

rule convert_neutralization_data_into_initial_titers_format:
    input:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_renamed.csv",
    output:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_initial_titers.csv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk mutate2 -n serum_id -e '$individual + "-" + $day_order' {input.data} \
            | csvtk replace -f day_order -p "day0" -r "pre" \
            | csvtk replace -f day_order -p "day30" -r "post" \
            | csvtk cut -f strain,NT50,serum_id,individual,day_order \
            | csvtk rename -f strain,NT50,day_order -n virus_strain,titer,vaccination_status > {output.data}
        """

rule get_reference_strain_per_serum_id_by_max_titer:
    input:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_initial_titers.csv",
    output:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_reference_strain.csv",
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
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_initial_titers.csv",
        references="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_reference_strain.csv",
    output:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_titers.tsv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk join -f serum_id {input.data} {input.references} \
            | csvtk mutate2 -n source -e '"Loes2024"' \
            | csvtk cut -T -f virus_strain,serum_strain,serum_id,source,titer,individual,vaccination_status > {output.data}
        """

rule filter_titers_by_vaccination_status:
    input:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_titers.tsv",
    output:
        data="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_titers/{vaccination_status}.tsv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        csvtk filter2 \
            -t \
            -f '$vaccination_status=="{wildcards.vaccination_status}"' \
            {input.data} > {output.data}
        """
