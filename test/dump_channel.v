module dump();
    initial begin
        $dumpfile ("channel.vcd");
        $dumpvars (0, channel);
        #1;
    end
endmodule
