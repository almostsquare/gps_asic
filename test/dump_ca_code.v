module dump();
    initial begin
        $dumpfile ("ca_code.vcd");
        $dumpvars (0, ca_code);
        #1;
    end
endmodule
