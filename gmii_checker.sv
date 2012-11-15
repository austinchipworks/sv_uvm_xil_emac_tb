`ifndef __GMII_CHECKER__
`define __GMII_CHECKER__

`include "ethernet_pkt.sv"

class gmii_checker extends uvm_agent ;

`uvm_component_utils(gmii_checker)

uvm_tlm_analysis_fifo #(ethernet_pkt) rx_mon_fifo ;
uvm_tlm_analysis_fifo #(ethernet_pkt) tx_mon_fifo ;

function new (string name="gmii_checker", uvm_component parent);
      super.new(name,parent);
      rx_mon_fifo = new("rx_mon_fifo",this);
      tx_mon_fifo = new("tx_mon_fifo",this);      
endfunction // new

function void build();
      super.build();
endfunction // void

task run();
      ethernet_pkt rx_pkt ;
      ethernet_pkt tx_pkt ;
      bit [47:0] swp ;
      fork
      forever
	begin
	   tx_mon_fifo.get(tx_pkt);
	   swp = tx_pkt.da ;
	   tx_pkt.da = tx_pkt.sa ;
	   tx_pkt.sa = swp;
	   rx_mon_fifo.get(rx_pkt);

	   if ( tx_pkt.compare(rx_pkt) )
	     begin
	     `uvm_info(this.get_name(),"**** PKT MATCH ******",UVM_NONE);
		tx_pkt.print();
	     end
	   else
	     `uvm_error(this.get_name(),"*** PKT MISMATCH *****");
	end
      join_none
	
endtask // run

endclass
  
`endif //  `ifndef __GMII_CHECKER__
  
