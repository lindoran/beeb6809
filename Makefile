PHONY: all clean cleanbin installbin check_dirs all_chipkit all_beeb all_matchbox all_flex all_sbc09


DEST = ~/hostfs
REQUIRED_DIRS = hostfs/beebroms hostfs/mods hostfs/roms69


all: check_dirs all_beeb all_chipkit all_flex all_matchbox all_sbc09
	$(MAKE) -C other-tests all

# Ensure all required directories exist
check_dirs:
	@echo "Checking required directories..."
	@for dir in $(REQUIRED_DIRS); do \
		if [ ! -d ./$$dir ]; then \
			echo "Directory $$dir is missing, creating..."; \
			mkdir -p ./$$dir; \
		else \
			echo "Directory $$dir exists."; \
		fi \
	done
	cp Makefile.bins ./hostfs/Makefile
	@echo "Directory check complete."


all_chipkit: check_dirs
	# NOTE: MOS/UTILS needs noice to be reinstated for chipkit somehow 
	# taken out to make room in MOS and moved into UTIL for beeb but
	# utils rom doesn't work yet for CHIPKIT
	$(MAKE) -C mos all_chipkit
	$(MAKE) -C rom-dev all_chipkit
	$(MAKE) -C chipkitmk1-tests all_chipkit
	$(MAKE) -C games all_chipkit
	$(MAKE) -C demos all_chipkit
	$(MAKE) -C ssds all_chipkit


ROMPARTS= 	CHIPKIT/mos/beeb6809-mos/mosrom.bin \
		CHIPKIT/rom-dev/BBCBASIC/6809bas.bin \
		CHIPKIT/rom-dev/HOSTFS/HOSTFS-ck.bin
ROM= CHIPKIT/ROMIMAGE.BIN

chipkit_rom: check_dirs
	$(MAKE) -C mos/beeb6809-mos all_chipkit
	$(MAKE) -C rom-dev/BBCBASIC all_chipkit
	$(MAKE) -C rom-dev/HOSTFS all_chipkit
	$(MAKE) $(ROM)

$(ROM): $(ROMPARTS)
	$(eval T := $(shell mktemp))
	touch $(T)
	dd if=CHIPKIT/mos/beeb6809-mos/mosrom.bin of=$(T) bs=16384
	dd if=CHIPKIT/rom-dev/BBCBASIC/6809bas.bin of=$(T) bs=16384 seek=1 conv=nocreat
	dd if=CHIPKIT/rom-dev/HOSTFS/HOSTFS-ck.bin of=$(T) bs=16384 seek=2 conv=nocreat
	mv $(T) $(ROM)

		
all_beeb: check_dirs
	$(MAKE) -C mos all_beeb
	$(MAKE) -C rom-dev all_beeb
	$(MAKE) -C games all_beeb
	$(MAKE) -C demos all_chipkit
	$(MAKE) -C ssds_beeb all_beeb
	$(MAKE) -C hardware-testing all_beeb
	$(MAKE) -C flex-port all_beeb
	
all_matchbox: check_dirs
	$(MAKE) -C rom-dev all_matchbox

all_flex: check_dirs
	$(MAKE) -C rom-dev all_flex
	$(MAKE) -C flex-port all_flex

all_sbc09: check_dirs
	$(MAKE) -C rom-dev all_sbc09
	$(MAKE) -C mos all_beeb   # we need to build the BEEB folder for dependancies 
	$(MAKE) -C mos all_sbc09
	
clean:
	$(MAKE) -C rom-dev clean
	$(MAKE) -C mos clean
	$(MAKE) -C chipkitmk1-tests clean
	$(MAKE) -C games clean
	$(MAKE) -C demos clean
	$(MAKE) -C ssds clean
	$(MAKE) -C other-tests all
	$(MAKE) -C hostfs clean
	-rm -f ROMIMAGE.BIN	

cleanbin:
	-rm -rf BEEB
	-rm -rf SBC09
	-rm -rf FLEX
	-rm -rf MATCHBOX
	-rm -rf CHIPKIT 
	-rm -rf hostfs

# Move files from ./hostfs to ~/hostfs  To keep legacy source projects outside of beeb6809 up to date.
installbin:  
	@echo "Installing files from ./hostfs to $(DEST)..."
	@mkdir -p $(DEST)  # Ensure the destination directory exists
	@rsync -av --progress hostfs/ $(DEST)  # Sync files while preserving structure
	@echo "Installation complete!"

	
	
