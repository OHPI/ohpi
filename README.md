[![Build Status](https://travis-ci.org/OHPI/ohpi.svg?branch=master)](https://travis-ci.org/OHPI/ohpi)
[![DOI](https://zenodo.org/badge/13996/OHPI/ohpi.svg)](https://zenodo.org/badge/latestdoi/13996/OHPI/ohpi)

# OHPI: Ontology of Host-Pathogen Interactions

OHPI is a community-driven ontology of host-pathogen interactions (OHPI) and represents the virulence factors (VFs) and how the mutants of VFs in the [Victors](http://www.phidias.us/victors/index.php) database become less virulence inside a host organism or host cells. It is developed to represent manually curated HPI knowledge available in the [PHIDIAS](http://www.phidias.us) resource .

**Example:** The OHPI object property ‘gene mutant attenuated in host cell’ represents a relation between a gene and a host cell where the microbial mutant lacking the gene is attenuated in the host cell compared to the wild type microbe. Such an object property can be used to represent a virulence factor and its interaction in a host cell, e.g., the ugpB gene of *Brucella spp.* and human epithelial cell line HeLa cell line where the ugpB mutant of *Brucella spp.* is attenuated in HeLa cells.

## Relevant links
- Ontology discussion mailing-list: ohpi-discuss@googlegroups.com
- Disussion forum: https://groups.google.com/forum/?hl=en#!forum/ohpi-discuss

## Reference

Sayers S, Li L, Ong E, Deng S, Fu G, Lin Y, Yang B, Zhang S, Fa Z, Zhao B, Xiang Z, Li Y, Zhao Z, Olszewski MA, Chen L, He Y. Victors: a web-based knowledge base of virulence factors in human and animal pathogens. Nucleic Acid Research. 2019 Jan 8;47(D1):D693-D700. doi: 10.1093/nar/gky999. [PMID: 30365026](https://www.ncbi.nlm.nih.gov/pubmed/30365026). PMCID: [PMC6324020](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6324020/).

More detail about OHPI can be found in the supplemental data from the paper: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6324020/bin/gky999_supplemental_files.pdf


More information can be found at http://obofoundry.org/ontology/ohpi

## Download

### Stable release versions

The latest version of the ontology can always be found at:

http://purl.obolibrary.org/obo/ohpi.owl

### Editors' version

Editors of this ontology should use the edit version, [src/ontology/ohpi-edit.owl](src/ontology/ohpi-edit.owl)

## Contact

Please use this GitHub repository's [Issue tracker](https://github.com/OHPI/ohpi/issues) to request new terms/classes or report errors or specific concerns related to the ontology.

## Acknowledgements

This ontology repository was created using the [ontology starter kit](https://github.com/INCATools/ontology-starter-kit)
