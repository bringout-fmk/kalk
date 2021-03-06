liball: 
	make -C adm/1g
	make -C mag/db/1g
	make -C mag/rpt/1g
	make -C mag/rpt/2g
	make -C mag/dok/1g
	make -C mag/konsig/1g
	make -C mag/razdb/1g
	make -C mag/gendok/1g
	make -C main/1g
	make -C main/2g
	make -C integ
	make -C db/1g
	make -C db/2g
	make -C dok/1g
	make -C razdb/1g
	make -C razoff/1g
	make -C rpt/1g
	make -C sif/1g
	make -C specif/jerry/1g
	make -C specif/inters/1g
	make -C specif/planika/1g
	make -C specif/tvin/1g
	make -C specif/vindija/1g
	make -C prod/db/1g
	make -C prod/dok/1g
	make -C prod/gendok/1g
	make -C prod/razdb/1g
	make -C prod/rpt/1g
	make -C vt/1g
	make -C gendok/1g
	make -C param/1g
	make -C ut/1g
	make -C primpak/1g
	make -C si/1g
	make -C proizvod/1g
	make -C 1g exe
	
cleanall:
	cd adm/1g; make clean
	cd mag/db/1g; make clean
	cd mag/rpt/1g; make clean
	cd mag/rpt/2g; make clean
	cd mag/dok/1g; make clean
	cd mag/konsig/1g; make clean
	cd mag/razdb/1g; make clean
	cd mag/gendok/1g; make clean
	cd main/1g; make clean
	cd main/2g; make clean
	cd integ; make clean
	cd db/1g; make clean
	cd db/2g; make clean
	cd dok/1g; make clean
	cd razdb/1g; make clean
	cd razoff/1g; make clean
	cd rpt/1g; make clean
	cd sif/1g; make clean
	cd specif/inters/1g; make clean
	cd specif/planika/1g; make clean
	cd specif/tvin/1g; make clean
	cd specif/vindija/1g; make clean
	cd prod/db/1g; make clean
	cd prod/dok/1g; make clean
	cd prod/gendok/1g; make clean
	cd prod/razdb/1g; make clean
	cd prod/rpt/1g; make clean
	cd ut/1g; make clean 
	cd vt/1g; make clean
	cd gendok/1g; make clean
	cd param/1g; make clean
	cd ut/1g; make clean
	cd primpak/1g; make clean
	cd si/1g; make clean
	cd proizvod/1g; make clean
	cd 1g; make clean


kalk:  start_time cleanall liball end_time 


start_time:
	$(shell echo start `date`  > /tmp/make_info)
 
end_time:
	$(shell echo end `date`  >> /tmp/make_info)
