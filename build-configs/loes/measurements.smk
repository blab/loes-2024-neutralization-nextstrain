ruleorder: concat_custom_measurements > concat_measurements

rule calculate_log2_titer_for_loes_measurements:
    input:
        titers="loes_data/standard_titers.tsv",
    output:
        titers="loes_data/log2_titers.tsv",
    conda: "../../../workflow/envs/nextstrain.yaml"
    shell:
        """
        python3 loes-neutralization-models/scripts/calculate_log2_titer.py \
            --titers {input.titers} \
            --output {output.titers}
        """

rule export_loes_measurements:
    input:
        titers="loes_data/log2_titers.tsv",
    output:
        measurements="builds/{build_name}/{segment}/measurements_loes.json",
    conda: "../../../workflow/envs/nextstrain.yaml"
    params:
        key="DRIVE_NT50",
        strain_column="virus_strain",
        value_column="log2_titer",
        title="log2 NT50s for pre- and post-vaccination DRIVE sera",
        x_axis_label="log2 NT50",
        thresholds=[0.0],
        grouping_columns=[
            "serum_id",
            "individual",
            "day_order",
        ],
        measurements_display="raw",
        include_columns=[
            "virus_strain",
            "titer",
            "log2_titer",
            "serum_id",
            "individual",
            "day_order",
        ],
    shell:
        """
        augur measurements export \
            --collection {input.titers} \
            --key {params.key} \
            --strain-column {params.strain_column} \
            --value-column {params.value_column} \
            --title {params.title:q} \
            --x-axis-label {params.x_axis_label:q} \
            --thresholds {params.thresholds} \
            --grouping-column {params.grouping_columns:q} \
            --measurements-display {params.measurements_display} \
            --show-threshold \
            --hide-overall-mean \
            --include-columns {params.include_columns:q} \
            --minify-json \
            --output-json {output.measurements} 2>&1 | tee {log}
        """

rule concat_custom_measurements:
    input:
        custom_measurements="builds/{build_name}/{segment}/measurements_loes.json",
        measurements=get_titer_collections,
    output:
        measurements="auspice/{build_name}_{segment}_measurements.json",
    conda: "../../../workflow/envs/nextstrain.yaml"
    benchmark:
        "benchmarks/concat_measurements_{build_name}_{segment}.txt"
    log:
        "logs/concat_measurements_{build_name}_{segment}.txt"
    shell:
        """
        augur measurements concat \
            --jsons {input.custom_measurements} {input.measurements} \
            --minify-json \
            --output-json {output.measurements} 2>&1 | tee {log}
        """
