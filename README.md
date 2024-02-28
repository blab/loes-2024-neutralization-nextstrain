# Analysis of neutralization data from Loes et al. 2024

Phylogenetic analysis and visualization of H1N1pdm neutralization data from Loes et al. 2024

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

Run the workflow with the build config for this analysis.

``` bash
nextstrain build . --configfile loes-neutralization-models/build-configs/loes.yaml
```
