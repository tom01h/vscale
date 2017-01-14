<img src="http://albert-magyar.github.io/vscale/vscale.svg">

# vscale

In order to build and test vscale using the supplied makefile,  
ModelSim must be installed and on the path.  
or verilator 3.884 or lator must be installed and on the path.

```
cd vscale
make modelsim-sim
make modelsim-run-asm-tests
```
or
```
cd vscale
make verilator-sim
make verilator-run-asm-tests
```
If verilator 3.882 or earlier, remove "--l2-name v" option in Makefile
