# Analysis of neutralization data from Loes et al. 2024

Phylogenetic analysis and visualization of H1N1pdm neutralization data from [Loes et al. 2024](https://github.com/jbloomlab/flu_seqneut_DRIVE_2021-22_repeat_vax/).

[Explore the tree and measurements panel on nextstrain.org](https://nextstrain.org/groups/blab/loes-2024/ha?p=grid).

## Run the workflow

[Install the Nextstrain CLI](https://docs.nextstrain.org/en/latest/install.html).
Clone the seasonal flu workflow.

``` bash
git clone https://github.com/nextstrain/seasonal-flu.git
cd seasonal-flu
```

Clone this repository into the flu workflow directory.

``` bash
git clone https://github.com/blab/loes-2024-neutralization-nextstrain.git
```

Run the workflow with the build config for this analysis.

``` bash
nextstrain build . --configfile loes-2024-neutralization-nextstrain/build-configs/loes.yaml
```
