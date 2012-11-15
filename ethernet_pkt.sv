`ifndef __ETHERNET_PKT__
`define __ETHERNET_PKT__

class ethernet_pkt extends uvm_sequence_item ;

`protect
static int pkt_count = 0;
byte bytestream[$] ;

rand bit [55:0] preamble ;
rand byte sfd ;
rand bit [47:0] da;
rand bit [47:0] sa ;
rand bit [15:0] length;
rand byte data[$];
rand bit [31:0] fcs;
rand bit [31:0] calc_fcs;

rand int unsigned payload_length ;

constraint preamble_c { preamble == 56'h55555555555555; }
constraint sfd_c { sfd == 8'hd5; }
constraint payload_length_c { payload_length inside {[46:1500]}; data.size() == payload_length; }

`uvm_object_utils_begin(ethernet_pkt)

`uvm_field_int( preamble, UVM_ALL_ON | UVM_NOPACK );
`uvm_field_int( sfd, UVM_ALL_ON | UVM_NOPACK );
`uvm_field_int( da, UVM_ALL_ON | UVM_NOPACK );
`uvm_field_int( sa, UVM_ALL_ON | UVM_NOPACK );
`uvm_field_int( length, UVM_ALL_ON | UVM_NOPACK | UVM_DEC );
`uvm_field_queue_int( data, UVM_ALL_ON | UVM_NOPACK );

`uvm_field_int( fcs, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOMPARE );
`uvm_field_int( payload_length, UVM_ALL_ON | UVM_NOPACK | UVM_DEC | UVM_ABSTRACT | UVM_NOCOMPARE);
`uvm_field_int( calc_fcs, UVM_ALL_ON | UVM_NOPACK | UVM_ABSTRACT | UVM_NOCOMPARE);

`uvm_object_utils_end

function new(string name="ethernet_pkt");
      super.new(name);
      pkt_count++;
endfunction // new

function void post_randomize();
      length = payload_length ;

      do_calc_fcs();
      fcs = calc_fcs ;
endfunction // void

task  do_calc_fcs() ;
      byte unsigned byte_array[];
      int unsigned num_bytes ;
      bit [31:0] tmp ;
      
      this.pack_bytes( byte_array );
      num_bytes = byte_array.size();

      calc_fcs = 32'hffffffff;
      for (int i=8;i<num_bytes-4;i++)
	calc_fcs = nextCRC32_D8( byte_array[i],calc_fcs);
      //Invert
      calc_fcs = ~calc_fcs ;
      //Bit reverse
      calc_fcs = { << {calc_fcs} };
      //Byte reverse
      calc_fcs = { << 8{calc_fcs}};
endtask

function bit [31:0] nextCRC32_D8 (bit [7:0] Data, bit [31:0] crc);

    reg [7:0] d;
    reg [31:0] c;
    reg [31:0] newcrc;

    d = Data;
    c = crc;
      
      newcrc[0] = c[30] ^ d[1] ^ c[24] ^ d[7];
      newcrc[1] = d[6] ^ d[7] ^ d[0] ^ c[30] ^ c[31] ^ d[1] ^ c[24] ^ c[25];
      newcrc[2] = c[26] ^ d[5] ^ d[6] ^ d[7] ^ c[30] ^ d[0] ^ d[1] ^ c[31] ^ c[24] ^ c[25];
      newcrc[3] = d[4] ^ c[26] ^ d[5] ^ c[27] ^ d[6] ^ d[0] ^ c[31] ^ c[25];
      newcrc[4] = d[4] ^ c[26] ^ d[5] ^ c[27] ^ c[28] ^ d[7] ^ c[30] ^ d[1] ^ c[24] ^ d[3];
      newcrc[5] = d[4] ^ c[27] ^ d[6] ^ c[28] ^ d[7] ^ c[29] ^ c[30] ^ d[0] ^ d[1] ^ c[31] ^ d[2] ^ c[24] ^ d[3] ^ c[25];
      newcrc[6] = c[26] ^ d[5] ^ d[6] ^ c[28] ^ c[29] ^ d[0] ^ c[30] ^ c[31] ^ d[1] ^ d[2] ^ d[3] ^ c[25];
      newcrc[7] = d[4] ^ c[26] ^ d[5] ^ c[27] ^ d[7] ^ c[29] ^ d[0] ^ c[31] ^ d[2] ^ c[24];
      newcrc[8] = d[4] ^ c[27] ^ d[6] ^ c[28] ^ d[7] ^ c[24] ^ c[0] ^ d[3] ^ c[25];
      newcrc[9] = c[26] ^ d[5] ^ d[6] ^ c[28] ^ c[29] ^ d[2] ^ d[3] ^ c[25] ^ c[1];
      newcrc[10] = d[4] ^ c[26] ^ c[2] ^ d[5] ^ c[27] ^ d[7] ^ c[29] ^ d[2] ^ c[24];
      newcrc[11] = d[4] ^ c[27] ^ d[6] ^ c[3] ^ c[28] ^ d[7] ^ c[24] ^ d[3] ^ c[25];
      newcrc[12] = c[26] ^ d[5] ^ d[6] ^ c[28] ^ d[7] ^ c[4] ^ c[29] ^ c[30] ^ d[1] ^ d[2] ^ c[24] ^ d[3] ^ c[25];
      newcrc[13] = d[4] ^ c[26] ^ d[5] ^ c[27] ^ d[6] ^ c[29] ^ d[0] ^ c[30] ^ c[5] ^ c[31] ^ d[1] ^ d[2] ^ c[25];
      newcrc[14] = d[4] ^ c[26] ^ d[5] ^ c[27] ^ c[28] ^ c[30] ^ d[0] ^ d[1] ^ c[31] ^ c[6] ^ d[3];
      newcrc[15] = d[4] ^ c[27] ^ c[28] ^ c[29] ^ d[0] ^ c[31] ^ d[2] ^ c[7] ^ d[3];
      newcrc[16] = c[28] ^ d[7] ^ c[29] ^ d[2] ^ c[24] ^ d[3] ^ c[8];
      newcrc[17] = c[9] ^ d[6] ^ c[29] ^ c[30] ^ d[1] ^ d[2] ^ c[25];
      newcrc[18] = c[26] ^ d[5] ^ c[10] ^ c[30] ^ d[0] ^ d[1] ^ c[31];
      newcrc[19] = d[4] ^ c[27] ^ c[11] ^ d[0] ^ c[31];
      newcrc[20] = c[28] ^ c[12] ^ d[3];
      newcrc[21] = c[29] ^ c[13] ^ d[2];
      newcrc[22] = d[7] ^ c[14] ^ c[24];
      newcrc[23] = d[6] ^ d[7] ^ c[30] ^ d[1] ^ c[15] ^ c[24] ^ c[25];
      newcrc[24] = c[26] ^ d[5] ^ d[6] ^ d[0] ^ c[31] ^ c[16] ^ c[25];
      newcrc[25] = d[4] ^ c[17] ^ c[26] ^ d[5] ^ c[27];
      newcrc[26] = d[4] ^ c[18] ^ c[27] ^ c[28] ^ d[7] ^ c[30] ^ d[1] ^ c[24] ^ d[3];
      newcrc[27] = d[6] ^ c[19] ^ c[28] ^ c[29] ^ d[0] ^ c[31] ^ d[2] ^ d[3] ^ c[25];
      newcrc[28] = c[26] ^ d[5] ^ c[20] ^ c[29] ^ c[30] ^ d[1] ^ d[2];
      newcrc[29] = d[4] ^ c[27] ^ c[21] ^ c[30] ^ d[0] ^ d[1] ^ c[31];
      newcrc[30] = c[28] ^ d[0] ^ c[22] ^ c[31] ^ d[3];
      newcrc[31] = c[29] ^ c[23] ^ d[2];

    return(newcrc);
      
endfunction // nextCRC32_D8

function void do_pack( uvm_packer packer);
      super.do_pack(packer);

      packer.pack_field_int( preamble, $bits(preamble));
      packer.pack_field_int( sfd , $bits(sfd) );
      packer.pack_field_int( da, $bits(da));
      packer.pack_field_int( sa, $bits(sa));
      packer.pack_field_int( length, $bits(length));
      foreach( data[i] )
        packer.pack_field_int( data[i], $bits(data[i]));
      packer.pack_field_int( fcs, $bits(fcs));            

endfunction // void

task pack();
      bytestream = { >> {preamble,sfd,da,sa,length,data,fcs}};
endtask // pack

function void do_unpack( uvm_packer packer);
      int num_bytes;
/*
      super.do_unpack(packer);

      //get_packed_size gives the number of bits
      //divide by 8 (leftshift 3)  to get number of bytes
      num_bytes = packer.get_packed_size();
      num_bytes >>= 3 ;

      payload_length = num_bytes - 26 ;
      
      preamble = packer.unpack_field_int( $bits(preamble) ) ;
      sfd = packer.unpack_field_int( $bits(sfd) ) ;
      da = packer.unpack_field_int( $bits(da));
      sa = packer.unpack_field_int( $bits(sa));
      length = packer.unpack_field_int( $bits(length));

      
      data = new[payload_length] ;
      foreach( data[i] )
        data[i] = packer.unpack_field_int( 8 );

      fcs = packer.unpack_field_int( $bits(fcs));            
*/
      
endfunction // void

task unpack() ;
      { >> {preamble,sfd,da,sa,length,data,fcs}} = bytestream ;
      do_calc_fcs();
endtask // unpack

`endprotect

endclass
  
`endif //  `ifndef __ETHERNET_PKT__
  
