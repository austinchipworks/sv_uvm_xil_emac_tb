`ifndef __GMII_MONITOR__
`define __GMII_MONITOR__

import global_pkg::*;
import uvm_pkg::*;

`include "ethernet_pkt.sv"

class gmii_monitor extends uvm_monitor ;

`uvm_component_utils(gmii_monitor)

uvm_analysis_port #(ethernet_pkt) mon_export ;

virtual gmii_mon_intf  intf ;
int unsigned pkt_count ;

function new(string name, uvm_component parent);
      super.new(name,parent);
      pkt_count = 0;
      mon_export = new("mon_export",this);
endfunction

function int unsigned get_pkt_count();
      return pkt_count ;
endfunction // int

function void build_phase( uvm_phase phase);
      super.build_phase(phase);
      uvm_resource_db #(virtual gmii_mon_intf)::read_by_name(this.get_name(), "intf", intf,null);
endfunction

function void connect_phase(uvm_phase phase) ;
      super.connect_phase(phase);
endfunction

task main_phase(uvm_phase phase);
      fork
	 int count ;
	 ethernet_pkt pkt ;

	 forever
	   begin
	      count = 0;
	      @(intf.pclk);
	      if ( intf.valid == 1 )
		begin
		   `uvm_info(this.get_name(),"SOP",UVM_NONE);
		   pkt = new("pkt");
		   do
		     begin
			pkt.bytestream.push_back(intf.data);
			count = count + 1;
			
			@(intf.pclk);
			if ( intf.valid == 0 ) 
			  begin
			     `uvm_info(this.get_name(),"******EOP",UVM_NONE);
			     pkt.unpack();
			     mon_export.write( pkt );
			     pkt = null ;
			     count = 0;
			     pkt_count++;
			  end
		     end
		   while ( count );
		end
	   end
     join_none
endtask 

endclass
  
`endif //  `ifndef __GMII_MONITOR__
  
