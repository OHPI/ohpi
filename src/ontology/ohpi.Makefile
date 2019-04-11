## Customize Makefile settings for ohpi
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

all_main: $(ONT)-merge.owl $(ONT)-merge.obo $(ONT)-merge.json

# ----------------------------------------
# Additional ODK Mirror/Import
# ----------------------------------------
#

IMP=true # Global parameter to bypass import generation
MIR=true # Global parameter to bypass mirror generation


## ONTOLOGY: doid
## Copy of doid is re-downloaded whenever source changes
## Special treatment to DOID
## 1. Remove DOID imports.
## 2. The following terms are removed:
##     NCBITaxon_1
##     NCBITaxon_131567
##     chebi
mirror/doid.owl: mirror/doid.trigger
	@if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/doid.owl -o $@.tmp.owl && \
	$(ROBOT) remove --select imports --input $@.tmp.owl \
	remove --term NCITaxon_1 \
	remove --term NCBITaxon_131567 \
	remove --term chebi && \
	mv $@.tmp.owl $@; fi

.PRECIOUS: mirror/%.owl

# ----------------------------------------
# Ontofox Import
# ----------------------------------------
#

FOX=true

ONTOFOX_IMPORTS = cl clo ino ido idobru ncbitaxon

ONTOFOX_IMPORT_ROOTS = $(patsubst %, imports/%_import, $(ONTOFOX_IMPORTS))
ONTOFOX_IMPORT_FILES = $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(foreach f,$(FORMATS), $(n).$(f)))
ONTOFOX_IMPORT_OWL_FILES = $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(n).owl)

all_imports: ontofox_imports ogg-victors_import

ontofox_imports: $(ONTOFOX_IMPORT_FILES)

ontofox_imports_owl: $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(n).owl)
 
ontofox_imports_obo: $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(n).obo)
 
ontofox_imports_json: $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(n).json)


imports/%_import.owl: ontofox/%_input.txt
	@if [ $(FOX) = true ] && [ $(IMP) = true ]; then curl -s -F file=@$< -o $@.tmp.owl http://ontofox.hegroup.org/service.php && $(ROBOT) \
	annotate -i $@.tmp.owl --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/%_import.owl

## Special treatment to CLO
imports/clo_import.owl: ontofox/clo_input.txt
	@if [ $(FOX) = true ] && [ $(IMP) = true ]; then curl -s -F file=@$< -o $@.tmp.owl http://ontofox.hegroup.org/service.php && \
	echo -e "old,new\nhttp://www.ebi.ac.uk/efo/EFO_0000979,http://purl.obolibrary.org/obo/UBERON_0000002" > $@.tmp.csv && \
	$(ROBOT) annotate -i $@.tmp.owl --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ \
	rename --mappings $@.tmp.csv --output $@.tmp.owl && mv $@.tmp.owl $@ && rm $@.tmp.csv; fi
.PRECIOUS: imports/%_import.owl

# ----------------------------------------
# Special Import - ogg-victors
# ----------------------------------------
#

ogg-victors_import: imports/ogg-victors_import.owl imports/ogg-victors_import.obo imports/ogg-victors_import.json

imports/ogg-victors_import.owl: mirror/ogg-victors.owl
	$(ROBOT) annotate -i $< --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: imports/%_import.owl

imports/ogg-victors_import.obo: imports/ogg-victors_import.owl
	@if [ $(IMP) = true ]; then $(ROBOT) convert --check false -i $< -f obo -o $@.tmp.obo && mv $@.tmp.obo $@; fi

imports/ogg-victors_import.json: imports/ogg-victors_import.owl
	@if [ $(IMP) = true ]; then $(ROBOT) convert --check false -i $< -f json -o $@.tmp.json && mv $@.tmp.json $@; fi

# ----------------------------------------
# Export Formats
# ----------------------------------------

## Merge: The merge artefacts with imports merged
$(ONT)-merge.owl: $(SRC) $(OTHER_SRC)
	$(ROBOT) merge --input $< \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@		

$(ONT)-merge.obo: $(ONT)-merge.owl
	$(ROBOT) annotate --input $< --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ \
		convert --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo
$(ONT)-merge.json: $(ONT)-merge.owl
	$(ROBOT) annotate --input $< --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ \
		convert --check false -f json -o $@.tmp.json && mv $@.tmp.json $@

# ----------------------------------------
# Release Management
# ----------------------------------------

ASSETS += $(ONTOFOX_IMPORT_FILES) $(ONT)-merge.owl $(ONT)-merge.obo $(ONT)-merge.json

# ----------------------------------------
# Clean
# ----------------------------------------

clean: clean_imports clean_ontofox clean_main clean_report clean_subset

clean_imports:
	rm $(IMPORT_FILES)

clean_ontofox: 
	rm $(ONTOFOX_IMPORT_FILES)

clean_main:
	rm $(MAIN_FILES)

clean_report:
	rm $(REPORT_FILES)

clean_subset:
	rm $(SUBSET_FILES)
