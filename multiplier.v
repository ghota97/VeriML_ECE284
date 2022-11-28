module FA1(Cout, S, A, B, Cin);
    input A, B, Cin;
    output Cout, S;
    wire S1, C1, C2;
    
    xor(S1, A, B);
    and(C1, A, B);
    xor(S, S1, Cin);
    and(C2, S1, Cin);
    or(Cout, C1, C2);
endmodule
 
module Node1(HCout, VCout, A, B, HCin, VCin);
    input A, B, HCin, VCin;
    output HCout, VCout;
    wire W1;
    
    assign W1 = A&B;
    FA1 fa1(HCout, VCout, W1, VCin, HCin);
endmodule
 
module multiplier(p, a, b);
    input [3:0] a, b;
    output [7:0] p;
    wire [3:0] sum0, sum1, sum2, sum3, sum4, sum5, sum6;
    wire [3:0] c0, c1, c2, c3, c4, c5, c6;
    
    // First row
    Node1 node0(c0[0], sum0[0], a[0], b[0], 1'b0, 1'b0);
    Node1 node1(c1[0], sum1[0], a[1], b[0], c0[0], 1'b0);
    Node1 node2(c2[0], sum2[0], a[2], b[0], c1[0], 1'b0);
    Node1 node3(c3[0], sum3[0], a[3], b[0], c2[0], 1'b0);
    // Second row
    Node1 node4(c1[1], sum1[1], a[0], b[1], 1'b0, sum1[0]);
    Node1 node5(c2[1], sum2[1], a[1], b[1], c1[1], sum2[0]);
    Node1 node6(c3[1], sum3[1], a[2], b[1], c2[1], sum3[0]);
    Node1 node7(c4[1], sum4[1], a[3], b[1], c3[1], c3[0]);
    // Third row
    Node1 node8(c2[2], sum2[2], a[0], b[2], 1'b0, sum2[1]);
    Node1 node9(c3[2], sum3[2], a[1], b[2], c2[2], sum3[1]);
    Node1 node10(c4[2], sum4[2], a[2], b[2], c3[2], sum4[1]);
    Node1 node11(c5[2], sum5[2], a[3], b[2], c4[2], c4[1]);
    // Forth row
    Node1 node12(c3[3], sum3[3], a[0], b[3], 1'b0, sum3[2]);
    Node1 node13(c4[3], sum4[3], a[1], b[3], c3[3], sum4[2]);
    Node1 node14(c5[3], sum5[3], a[2], b[3], c4[3], sum5[2]);
    Node1 node15(c6[3], sum6[3], a[3], b[3], c5[3], c5[2]);
    
    assign p[0] = sum0[0];
    assign p[1] = sum1[1];
    assign p[2] = sum2[2];
    assign p[3] = sum3[3];
    assign p[4] = sum4[3];
    assign p[5] = sum5[3];
    assign p[6] = sum6[3];
    assign p[7] = c6[3];
endmodule
