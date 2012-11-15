SRC =       ../../example_design/client/address_swap_module_8.v \
      ../../example_design/client/fifo/tx_client_fifo_8.v \
      ../../example_design/client/fifo/rx_client_fifo_8.v \
      ../../example_design/client/fifo/eth_fifo_8.v \
      ../../example_design/physical/gmii_if.v \
      ../../example_design/v5_emac_v1_8.v \
      ../../example_design/v5_emac_v1_8_block.v \
      ../../example_design/v5_emac_v1_8_locallink.v \
      ../../example_design/v5_emac_v1_8_example_design.v \
      $(XILINX)/verilog/src/glbl.v \
	global_pkg.sv \
	gmii_mon_intf.sv \
	gmii_drv_intf.sv \
	gmii_monitor.sv \
	gmii_driver.sv \
	ethernet_pkt.sv \
	default_run_test.sv \
	./tb_uvm.v 


build:  ntb_analyze src_analyze elab

ntb_analyze:
	vlogan -sverilog -ntb_opts uvm-1.1 -l ntb_analyze.log

src_analyze: $(SRC)
	vlogan +v2k -sverilog +incdir+.  -ntb_opts uvm-1.1  $(SRC) -l src_analyze.log

elab:
	vcs -debug -PP tb_uvm glbl -ntb_opts uvm -l elab.log

run: 
	./simv -ucli -i ucli_commands.key -l run.log

waves: 
	dve -vpd vcdplus.vpd -session vcs_session.tcl

clean:
	rm -rf AN.DB
	rm -rf	simv*
	rm -rf	csrc*
	rm -rf	*.vpd



