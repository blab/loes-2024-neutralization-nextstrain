# Analysis of neutralization data from Loes et al. 2024

Phylogenetic analysis and visualization of H1N1pdm neutralization data from [Loes et al. 2024](https://github.com/jbloomlab/flu_seqneut_DRIVE_2021-22_repeat_vax/).

[Explore the tree and measurements panel on nextstrain.org](https://nextstrain.org/groups/blab/loes-2024/ha?p=grid).

## Run the workflow

Clone the seasonal flu workflow.

``` bash
git clone https://github.com/nextstrain/seasonal-flu.git
cd seasonal-flu
```

Clone this repository into the flu workflow directory.

``` bash
git clone https://github.com/huddlej/loes-neutralization-models.git
```

Copy the neutralization data into the build config directory.

``` bash
cp ~/231006_NT50spreandpost_30individuals.csv loes-neutralization-models/build-configs/loes/
```

Run the workflow with the build config for this analysis.

``` bash
nextstrain build . --configfile loes-neutralization-models/build-configs/loes.yaml
```
