`ifndef __GMII_DRIVER__
`define __GMII_DRIVER__

import uvm_pkg::*;

`include "ethernet_pkt.sv"

class gmii_driver extends uvm_driver #(ethernet_pkt) ;

`uvm_component_utils(gmii_driver)

virtual gmii_drv_intf  intf ;
mailbox drv_mbox ;

function new(string name, uvm_component parent);
      super.new(name,parent);
endfunction
  
function void build_phase( uvm_phase phase);
      super.build_phase(phase);
      uvm_resource_db #(virtual gmii_drv_intf)::read_by_name(this.get_name(), "intf", intf,null);
      uvm_resource_db #(mailbox)::read_by_name(this.get_name(), "mailbox", drv_mbox,null);
endfunction

function void connect_phase(uvm_phase phase) ;
      super.connect_phase(phase);
endfunction

task main_phase(uvm_phase phase);
      fork
	 begin
	    ethernet_pkt pkt ;
	    intf.valid = 0;
	    intf.data = 0;
	    intf.err = 0;
	    
	    wait ( intf.config_busy == 0 );
	    wait ( intf.config_busy == 1 );
	    wait ( intf.config_busy == 0 );

	    forever
	      begin
		 //drv_mbox.get(pkt);
		 seq_item_port.get_next_item(pkt);

		 pkt.pack() ;

		 foreach ( pkt.bytestream[i] )		 
       		 begin
		    @(intf.pclk);
		    intf.valid = 1 ;
		    intf.err = 0;
		    intf.data = pkt.bytestream[i] ;		    
		 end
		 @(intf.pclk);
		 intf.valid = 0;

		 seq_item_port.item_done();
		 
		 //Inter packet gap
		 repeat (200) @(intf.pclk) ;
		 
	      end // forever begin
	 end // fork begin
     join_none
endtask 

endclass
  
`endif //  `ifndef __GMII_DRIVER__
  
