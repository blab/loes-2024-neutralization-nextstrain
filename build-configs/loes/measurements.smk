ruleorder: concat_custom_measurements > concat_measurements

rule export_loes_measurements:
    input:
        distances="loes-neutralization-models/build-configs/loes/231006_NT50spreandpost_30individuals_titers.tsv",
    output:
        measurements="builds/{build_name}/{segment}/measurements_loes.json",
    conda: "../../../workflow/envs/nextstrain.yaml"
    params:
        key="DRIVE_NT50",
        strain_column="virus_strain",
        value_column="titer",
        title="NT50s for pre- and post-vaccination DRIVE sera",
        x_axis_label="NT50",
        thresholds=[0.0],
        grouping_columns=[
            "serum_id",
            "individual",
            "vaccination_status",
        ],
        measurements_display="raw",
        include_columns=[
            "virus_strain",
            "titer",
            "serum_id",
            "individual",
            "vaccination_status",
        ],
    shell:
        """
        augur measurements export \
            --collection {input.distances} \
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
