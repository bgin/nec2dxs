

nec2dxs: nec2dxs.f nec2dpar.inc
	clear
	gfortran -std=gnu -O -fno-automatic nec2dxs.f -o nec2dxs

clean:
	@rm -f *~ *.out nec2dxs

test: nec2dxs
	echo "G5RV.nec\nG5RV.out\n" | ./nec2dxs

