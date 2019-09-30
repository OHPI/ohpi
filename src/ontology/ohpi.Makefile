## Customize Makefile settings for ohpi
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

IMP=true # Global parameter to bypass import generation
MIR=true # Global parameter to bypass mirror generation

FOX=true # Global parameter to bypass ontofox import generation
MOD=true # Global parameter to bypass module generation

# ----------------------------------------
# Additional ODK Mirror/Import
# ----------------------------------------
#

all_imports: additional_imports

ADDITIONAL_IMPORTS = doid

ADDITIONAL_IMPORT_ROOTS = $(patsubst %, imports/%_import, $(ADDITIONAL_IMPORTS))
ADDITIONAL_IMPORT_FILES = $(foreach n,$(ADDITIONAL_IMPORT_ROOTS), $(foreach f,$(FORMATS), $(n).$(f)))
ADDITIONAL_IMPORT_OWL_FILES = $(foreach n,$(ADDITIONAL_IMPORT_ROOTS), $(n).owl)

additional_imports: $(ADDITIONAL_IMPORT_FILES)

additional_imports_owl: $(foreach n,$(ADDITIONAL_IMPORT_ROOTS), $(n).owl)
 
additional_imports_obo: $(foreach n,$(ADDITIONAL_IMPORT_ROOTS), $(n).obo)
 
additional_imports_json: $(foreach n,$(ADDITIONAL_IMPORT_ROOTS), $(n).json)


## ONTOLOGY: doid
## Copy of doid is re-downloaded whenever source changes
## Special treatment to DOID
## 1. Remove DOID imports.
## 2. The following terms are removed:
##     NCBITaxon_1
##     NCBITaxon_131567
##     chebi
mirror/doid.trigger: $(SRC)

mirror/doid.owl: mirror/doid.trigger
	@if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/doid.owl -o $@ && \
	$(ROBOT) remove --select imports --input $@ --output $@.tmp.owl && \
#	$(ROBOT) remove --select self --term NCITaxon_1 --input $@.tmp.owl --output $@.tmp.owl && \
#	remove --term NCBITaxon_131567 \
#	remove --term chebi  --output $@.tmp.owl && \
	mv $@.tmp.owl $@; fi

.PRECIOUS: mirror/%.owl


ASSETS += $(ADDITIONAL_IMPORT_FILES)

# ----------------------------------------
# Ontofox Import
# ----------------------------------------
#

all_imports: ontofox_imports

ONTOFOX_IMPORTS = cl clo ino ido idobru ncbitaxon vo

ONTOFOX_IMPORT_ROOTS = $(patsubst %, imports/%_import, $(ONTOFOX_IMPORTS))
ONTOFOX_IMPORT_FILES = $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(foreach f,$(FORMATS), $(n).$(f)))
ONTOFOX_IMPORT_OWL_FILES = $(foreach n,$(ONTOFOX_IMPORT_ROOTS), $(n).owl)

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


ASSETS += $(ONTOFOX_IMPORT_FILES)

# ----------------------------------------
# Special Import - ogg-victors
# ----------------------------------------
#

all_imports: ogg-victors_import

ogg-victors_import: imports/ogg-victors_import.owl imports/ogg-victors_import.obo imports/ogg-victors_import.json

mirror/ogg-victors.owl: ogg-victors.owl
	cp ogg-victors.owl mirror/ogg-victors.owl

imports/ogg-victors_import.owl: mirror/ogg-victors.owl
	$(ROBOT) annotate -i $< --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: imports/%_import.owl

imports/ogg-victors_import.obo: imports/ogg-victors_import.owl
	@if [ $(IMP) = true ]; then $(ROBOT) convert --check false -i $< -f obo -o $@.tmp.obo && mv $@.tmp.obo $@; fi

imports/ogg-victors_import.json: imports/ogg-victors_import.owl
	@if [ $(IMP) = true ]; then $(ROBOT) convert --check false -i $< -f json -o $@.tmp.json && mv $@.tmp.json $@; fi


ASSETS += imports/ogg-victors_import.owl imports/ogg-victors_import.obo imports/ogg-victors_import.json

# ----------------------------------------
# Modules
# ----------------------------------------

MODULES = victors-annotation victors-pathogen victors-host victors-interaction victors-protegen-gene victors-protegen-protein

MODULES_ROOTS = $(patsubst %, modules/%_module, $(MODULES))
MODULES_FILES = $(foreach n,$(MODULES_ROOTS), $(foreach f,$(FORMATS), $(n).$(f)))
MODULES_OWL_FILES = $(foreach n,$(MODULES_ROOTS), $(n).owl)

all_modules: $(MODULES_FILES)

all_modules_owl: $(foreach n,$(MODULES_ROOTS), $(n).owl)
 
all_modules_obo: $(foreach n,$(MODULES_ROOTS), $(n).obo)
 
all_modules_json: $(foreach n,$(MODULES_ROOTS), $(n).json)

#TODO:
#	Add the functionality to automatically generate modules from
#	1) ontorat/*_input.txt
#	2) victors/*_data.txt
#	3) ontorat/victors.template.owl
modules/%_module.owl:
	@if [ $(MOD) = true ]; then $(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ \
	--version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: modules/%_module.owl

modules/%_module.obo: modules/%_module.owl
	@if [ $(MOD) = true ]; then $(ROBOT) convert --check false -i $< -f obo -o $@.tmp.obo && mv $@.tmp.obo $@; fi
modules/%_module.json: modules/%_module.owl
	@if [ $(MOD) = true ]; then $(ROBOT) convert --check false -i $< -f json -o $@.tmp.json && mv $@.tmp.json $@; fi

ASSETS += $(MODULES_FILES)

# ----------------------------------------
# Export Formats
# ----------------------------------------

all_main: $(ONT)-merge.owl $(ONT)-merge.obo $(ONT)-merge.json

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


ASSETS += $(ONT)-merge.owl $(ONT)-merge.obo $(ONT)-merge.json

# ----------------------------------------
# Release
# ----------------------------------------
# This should be executed by the release manager whenever time comes to make a release.
# It will ensure that all assets/files are fresh, and will copy to release folder from staging area (this directory) to top-level
release: $(ASSETS) $(PATTERN_RELEASE_FILES)
	rsync -R $(ASSETS) $(RELEASEDIR) && \
	echo "Release files are now in $(RELEASEDIR) - now you should commit, push and make a release on github"

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
