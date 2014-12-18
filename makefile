# IBM_PROLOG_BEGIN_TAG
# This is an automatically generated prolog.
#
# $Source: makefile $
#
# OpenPOWER HostBoot Project
#
# Contributors Listed Below - COPYRIGHT 2014
# [+] International Business Machines Corp.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# IBM_PROLOG_END_TAG
################################################################################
## src/mrw/xml/data/makefile
################################################################################

$(if ${OUTPUT_PATH},, $(error OUTPUT_PATH must be defined) )
$(if ${PARSER_PATH},, $(error PARSER_PATH must be defined) )
$(if ${XSL_PATH},, $(error XSL_PATH must be defined) )
$(if ${SCHEMA_FILE},, $(error SCHEMA_FILE must be defined) )

# Uncomment to get extra debug statements from parser code
VERBOSE = --verbose

INTERMEDIATE_FILES_PATT = \
xxx-pre-include.xml \
xxx-full.xml \
xxx-targets.xml \
xxx-cec-chips.xml \
xxx-chip-ids.xml  \
xxx-dmi-busses.xml \
xxx-fsi-busses.xml \
xxx-fsi-presence.xml \
xxx-i2c-busses.xml \
xxx-i2c-presence.xml \
xxx-memory-busses.xml \
xxx-pcie-busses.xml \
xxx-cent-vrds.xml \
xxx-power.xml \
xxx-power-busses.xml \
xxx-mru-ids.xml \
xxx-location-codes.xml \
xxx-proc-spi-busses.xml

NON_BUILTS = \
    ${OUTPUT_PATH}/%-system-policy.xml \
    ${OUTPUT_PATH}/%-pm-settings.xml \
    ${OUTPUT_PATH}/%-proc-pcie-settings.xml \
    ${OUTPUT_PATH}/%-vddr.xml
.SECONDARY:
.DEFAULT_GOAL := error
error:
	@echo "Please specify a system name or target"

#delete the intermediate files, while keeping *-proc-chip-ids.xml (but not *-chip-ids.xml)
clean:
	rm -f ${OUTPUT_PATH}/*
	ls ${patsubst xxx%,*%,${INTERMEDIATE_FILES_PATT}} 2> /dev/null | grep -v proc-chip-ids | xargs rm -f
	rm -f *.html
	rm -f *.done

# Make target is the platform name that is the root for all XML file names referenced
$(patsubst clean,,$(MAKECMDGOALS)): $(patsubst %,%.done,$(MAKECMDGOALS))
	@echo "=== MRW for $(MAKECMDGOALS) was built ==="

%.done : %-full.xml %-targets.xml %-cec-chips.xml %-chip-ids.xml %-dmi-busses.xml %-fsi-busses.xml %-i2c-busses.xml %-memory-busses.xml %-pcie-busses.xml %-cent-vrds.xml %-power-busses.xml %-mru-ids.xml %-location-codes.xml %-proc-spi-busses.xml ${NON_BUILTS}
	touch $@

${OUTPUT_PATH}/%.xml:
	@echo "=== Copying non-built $@ ==="
	cp ${patsubst ${OUTPUT_PATH}/%,%, $@} ${OUTPUT_PATH}/

%-full.xml : %-pre-include.xml
	@echo "=== Generating Full XML document from $< ==="
	${PARSER_PATH}/mrwMergeElements ${VERBOSE} --in $< --out $@
	cp $@ ${OUTPUT_PATH}/

%-pre-include.xml : %.xml
	@echo "=== Generating XML document with includes resolved for $< ==="
	xmllint --xinclude $< >$@
	xmllint --schema ${SCHEMA_FILE} --noout $@
	cp $@ ${OUTPUT_PATH}/

%-targets.xml : %-full.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwTargetParser $(VERBOSE) --in $< --out $@
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${@}} ${XSL_PATH}/mrwTargets.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-location-codes.xml : %-full.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwLocationCodeParser --in $< --out $@
	cp $@ ${OUTPUT_PATH}/

%-cec-chips.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwCecChips --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwCecChips.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-chip-ids.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwChipIDs --in ${patsubst %-targets.xml,%-proc-chip-ids.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwChipIDs.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-dmi-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwDMIParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwDMIBusses.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-fsi-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwFSIParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $< --pres-out ${patsubst %-fsi-busses.xml,%-fsi-presence.xml,${@}}
	cp $@ ${OUTPUT_PATH}/
	cp ${patsubst %-fsi-busses.xml,%-fsi-presence.xml,${@}} ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwFSIBusses.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-i2c-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwI2CParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $< --pres-out ${patsubst %-i2c-busses.xml,%-i2c-presence.xml,${@}}
	cp $@ ${OUTPUT_PATH}/
	cp ${patsubst %-i2c-busses.xml,%-i2c-presence.xml,${@}} ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwI2CBusses.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-memory-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwMemParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwMemoryBusses.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-pcie-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwPCIEParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwPCIEBusses.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-cent-vrds.xml : %-i2c-busses.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwPower --in ${patsubst %-i2c-busses.xml,%-full.xml,${<}} --out ${patsubst %-cent-vrds.xml,%-power.xml,${@}} --targets ${patsubst %-cent-vrds.xml,%-targets.xml,${@}} --cent-vrd-out $@ --i2c $<
	cp $@ ${OUTPUT_PATH}/
	cp ${patsubst %-cent-vrds.xml,%-power.xml,${@}} ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-i2c-busses.xml,%,${<}} ${XSL_PATH}/mrwCentVRDs.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-power-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwPowerBusParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwPowerBusses.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-mru-ids.xml : %-pcie-busses.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwMruIdParser --fullin  ${patsubst %-pcie-busses.xml,%-full.xml,${<}} --mapin mru-type-mapping.xml --targets ${patsubst %-pcie-busses.xml,%-targets.xml,${<}} --pcie $< --xmlout $@
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-pcie-busses.xml,%,${<}} ${XSL_PATH}/mrwMruIds.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

%-proc-spi-busses.xml : %-targets.xml
	@echo "===== Generating $@ ====="
	${PARSER_PATH}/mrwProcSpiParser --in ${patsubst %-targets.xml,%-full.xml,${<}} --out $@ --targets $<
	cp $@ ${OUTPUT_PATH}/
	@echo "===== Generating ${patsubst %.xml,%.html,${@}} ====="
	xsltproc --output ${patsubst %.xml,%.html,${@}} --stringparam system ${patsubst %-targets.xml,%,${<}} ${XSL_PATH}/mrwProcSpi.xsl $@
	cp ${patsubst %.xml,%.html,${@}} ${OUTPUT_PATH}/

