import uvm_pkg::*;

`include "gmii_monitor.sv"
`include "gmii_driver.sv"
`include "default_pkt_sequence.sv"
`include "gmii_checker.sv"

class default_run_test extends uvm_test ;

`uvm_component_utils(default_run_test)

gmii_monitor tx_mon ;
gmii_monitor rx_mon ;

gmii_driver drv ;
gmii_checker checker ;

mailbox drv_mbox ;

uvm_sequencer #(ethernet_pkt) seqr ;

default_pkt_sequence seq ;

time countdown_interval ;

function new(string name, uvm_component parent);
      super.new(name,parent);
      drv_mbox = new(1);
      `uvm_info("", "Called default_run_test::new", UVM_NONE);
      countdown_interval = 1000ns;
endfunction: new

    function void  build_phase(uvm_phase phase);
      super.build_phase(phase);
      tx_mon = gmii_monitor::type_id::create("tx_mon",this);
      rx_mon = gmii_monitor::type_id::create("rx_mon",this);
      drv = gmii_driver::type_id::create("drv",this);
      uvm_resource_db #(mailbox)::set("drv","mailbox",drv_mbox,null);
      uvm_top.enable_print_topology = 1;
      seqr = new("seqr",this);
      seq = default_pkt_sequence::type_id::create("seq",this);
      checker = new("checker",this);
    endfunction

function void connect();
      drv.seq_item_port.connect(seqr.seq_item_export);
      tx_mon.mon_export.connect( checker.tx_mon_fifo.analysis_export );
      rx_mon.mon_export.connect( checker.rx_mon_fifo.analysis_export );
 endfunction // void

task main_phase(uvm_phase phase);

      ethernet_pkt pkt ;
      int num_pkts = 3;

      phase.raise_objection(this);

      seq.start(seqr);
      
/*      
      repeat (num_pkts)
	begin
	   //pkt = new("pkt");
	   pkt = ethernet_pkt::type_id::create("pkt");
	   pkt.randomize() with { payload_length==46;} ;
	   drv_mbox.put(pkt);
	end
*/
      
      while(tx_mon.get_pkt_count() < num_pkts )
	#(countdown_interval);
      
      phase.drop_objection(this);
    endtask // main_phase

 endclass

