`ifndef __DEFAULT_PKT_SEQUENCE__
`define __DEFAULT_PKT_SEQUENCE__

`include "ethernet_pkt.sv"

class default_pkt_sequence extends uvm_sequence #(ethernet_pkt);

int cnt = 10;
ethernet_pkt pkt ;

`uvm_object_utils_begin(default_pkt_sequence)
`uvm_field_int(cnt,UVM_ALL_ON);
`uvm_object_utils_end

  function new(string name = "default_pkt_sequence");
      super.new(name);
  endfunction // new

task body();
      repeat(cnt)
	begin
	   pkt = new("pkt");
	   start_item(pkt);
	   
	   pkt.randomize() with { payload_length == 46; } ;
	   
	   finish_item(pkt);
	end
endtask // body

endclass
  
`endif
