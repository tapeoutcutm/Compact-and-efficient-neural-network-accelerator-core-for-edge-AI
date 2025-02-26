module fp_add (
	op_a_i,
	op_b_i,
	result_o
);
	reg _sv2v_0;
	localparam tiny_nn_pkg_FPExpWidth = 8;
	localparam tiny_nn_pkg_FPMantWidth = 7;
	input wire [15:0] op_a_i;
	input wire [15:0] op_b_i;
	output reg [15:0] result_o;
	reg [15:0] op_x;
	reg [15:0] op_y;
	localparam FPMantWidthExt = 11;
	wire [10:0] op_x_full_mant;
	wire [10:0] op_y_full_mant;
	wire [10:0] op_y_full_mant_signed;
	wire [10:0] op_x_full_mant_signed;
	wire signed [10:0] foo;
	wire [10:0] op_y_full_mant_signed_shifted;
	reg [6:0] op_y_dropped_bits;
	wire [7:0] full_mant_shift;
	wire [2:0] mant_shift;
	wire [10:0] mant_add_signed;
	reg [10:0] mant_add;
	wire mant_add_sign;
	wire [tiny_nn_pkg_FPMantWidth:0] mant_add_norm_all [0:9];
	reg [tiny_nn_pkg_FPMantWidth:0] mant_add_norm;
	wire [6:0] mant_final;
	reg [2:0] exp_change;
	wire [6:0] result_mant;
	wire [7:0] result_exp;
	always @(*) begin
		if (_sv2v_0)
			;
		if (op_a_i[14-:8] >= op_b_i[14-:8]) begin
			op_x = op_a_i;
			op_y = op_b_i;
		end
		else begin
			op_x = op_b_i;
			op_y = op_a_i;
		end
	end
	assign op_x_full_mant = {3'b001, op_x[6-:tiny_nn_pkg_FPMantWidth], 1'b0};
	assign op_y_full_mant = {3'b001, op_y[6-:tiny_nn_pkg_FPMantWidth], 1'b0};
	assign full_mant_shift = op_x[14-:8] - op_y[14-:8];
	assign mant_shift = full_mant_shift[2:0];
	assign op_x_full_mant_signed = (op_x[15] ? ~(op_x_full_mant - 1'b1) : op_x_full_mant);
	assign op_y_full_mant_signed = (op_y[15] ? ~(op_y_full_mant - 1'b1) : op_y_full_mant);
	function automatic signed [2:0] sv2v_cast_3_signed;
		input reg signed [2:0] inp;
		sv2v_cast_3_signed = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		op_y_dropped_bits = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < tiny_nn_pkg_FPMantWidth; i = i + 1)
				if (mant_shift >= sv2v_cast_3_signed(i + 1))
					op_y_dropped_bits[i] = op_y_full_mant_signed[i];
		end
	end
	assign foo = $signed(op_y_full_mant_signed) >>> mant_shift;
	function automatic signed [7:0] sv2v_cast_8_signed;
		input reg signed [7:0] inp;
		sv2v_cast_8_signed = inp;
	endfunction
	assign op_y_full_mant_signed_shifted = (full_mant_shift <= sv2v_cast_8_signed(tiny_nn_pkg_FPMantWidth) ? $unsigned(foo) : {FPMantWidthExt {1'b0}});
	assign mant_add_signed = op_x_full_mant_signed + $unsigned(op_y_full_mant_signed_shifted);
	assign mant_add_sign = mant_add_signed[10];
	always @(*) begin
		if (_sv2v_0)
			;
		if (mant_add_sign) begin
			if (|op_y_dropped_bits && (full_mant_shift <= sv2v_cast_8_signed(tiny_nn_pkg_FPMantWidth)))
				mant_add = ~mant_add_signed;
			else
				mant_add = ~mant_add_signed + 1'b1;
		end
		else
			mant_add = mant_add_signed;
	end
	genvar _gv_i_norm_1;
	generate
		for (_gv_i_norm_1 = 0; _gv_i_norm_1 < 10; _gv_i_norm_1 = _gv_i_norm_1 + 1) begin : g_norm
			localparam i_norm = _gv_i_norm_1;
			if (i_norm == 9) begin : genblk1
				assign mant_add_norm_all[i_norm] = mant_add[i_norm:2];
			end
			else if (i_norm == 8) begin : genblk1
				assign mant_add_norm_all[i_norm] = mant_add[i_norm:1];
			end
			else begin : genblk1
				localparam [31:0] BottomFillWidth = tiny_nn_pkg_FPMantWidth - i_norm;
				assign mant_add_norm_all[i_norm] = {mant_add[i_norm:0], {BottomFillWidth {1'b0}}};
			end
		end
	endgenerate
	always @(*) begin
		if (_sv2v_0)
			;
		exp_change = 1'sb0;
		mant_add_norm = 1'sb0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 10; i = i + 1)
				if (mant_add[i]) begin
					mant_add_norm = mant_add_norm_all[i];
					if (i <= tiny_nn_pkg_FPMantWidth)
						exp_change = sv2v_cast_3_signed(tiny_nn_pkg_FPMantWidth - i);
				end
		end
	end
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	assign result_exp = (mant_add[9] ? op_x[14-:8] + 1'b1 : (mant_add[8] ? op_x[14-:8] : (op_x[14-:8] - 1'b1) - sv2v_cast_8(exp_change)));
	assign result_mant = mant_add_norm[6:0];
	function automatic [7:0] sv2v_cast_1B4FD;
		input reg [7:0] inp;
		sv2v_cast_1B4FD = inp;
	endfunction
	function automatic [6:0] sv2v_cast_938D1;
		input reg [6:0] inp;
		sv2v_cast_938D1 = inp;
	endfunction
	localparam [15:0] tiny_nn_pkg_FPNegInf = {1'b1, sv2v_cast_1B4FD(1'sb1), sv2v_cast_938D1(1'sb0)};
	localparam [15:0] tiny_nn_pkg_FPPosInf = {1'b0, sv2v_cast_1B4FD(1'sb1), sv2v_cast_938D1(1'sb0)};
	localparam [15:0] tiny_nn_pkg_FPStdNaN = {1'b1, sv2v_cast_1B4FD(1'sb1), sv2v_cast_938D1(1'sb1)};
	localparam [15:0] tiny_nn_pkg_FPZero = {1'b0, sv2v_cast_1B4FD(1'sb0), sv2v_cast_938D1(1'sb0)};
	function tiny_nn_pkg_is_inf;
		input reg [15:0] x;
		tiny_nn_pkg_is_inf = (x == tiny_nn_pkg_FPPosInf) || (x == tiny_nn_pkg_FPNegInf);
	endfunction
	function tiny_nn_pkg_is_nan;
		input reg [15:0] x;
		if (x[14-:8] == {8 {1'sb0}}) begin
			if (x[6-:tiny_nn_pkg_FPMantWidth] != {7 {1'sb0}})
				tiny_nn_pkg_is_nan = 1'b1;
			else if (x[15] == 1'b1)
				tiny_nn_pkg_is_nan = 1'b1;
			else
				tiny_nn_pkg_is_nan = 1'b0;
		end
		else if (x[14-:8] == {8 {1'sb1}}) begin
			if (x[6-:tiny_nn_pkg_FPMantWidth] != {7 {1'sb0}})
				tiny_nn_pkg_is_nan = 1'b1;
			else
				tiny_nn_pkg_is_nan = 1'b0;
		end
		else
			tiny_nn_pkg_is_nan = 1'b0;
	endfunction
	function automatic [7:0] sv2v_cast_76516;
		input reg [7:0] inp;
		sv2v_cast_76516 = inp;
	endfunction
	function automatic [6:0] sv2v_cast_5FAF8;
		input reg [6:0] inp;
		sv2v_cast_5FAF8 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		if (tiny_nn_pkg_is_nan(op_a_i) || tiny_nn_pkg_is_nan(op_b_i))
			result_o = tiny_nn_pkg_FPStdNaN;
		else if (tiny_nn_pkg_is_inf(op_a_i) && tiny_nn_pkg_is_inf(op_b_i)) begin
			if (op_a_i[15] != op_b_i[15])
				result_o = tiny_nn_pkg_FPStdNaN;
			else
				result_o = op_a_i;
		end
		else if (tiny_nn_pkg_is_inf(op_a_i))
			result_o = op_a_i;
		else if (tiny_nn_pkg_is_inf(op_b_i))
			result_o = op_b_i;
		else if (op_a_i == tiny_nn_pkg_FPZero)
			result_o = op_b_i;
		else if (op_b_i == tiny_nn_pkg_FPZero)
			result_o = op_a_i;
		else if (mant_add_signed == {11 {1'sb0}})
			result_o = tiny_nn_pkg_FPZero;
		else if (mant_add[9] && (op_x[14-:8] == (tiny_nn_pkg_FPPosInf[14-:8] - 1'b1)))
			result_o = (mant_add_sign ? tiny_nn_pkg_FPNegInf : tiny_nn_pkg_FPPosInf);
		else if ((mant_add[8+:2] == {2 {1'sb0}}) && ((1'b1 + sv2v_cast_8(exp_change)) >= op_x[14-:8]))
			result_o = tiny_nn_pkg_FPZero;
		else
			result_o = {mant_add_sign, sv2v_cast_76516(result_exp), sv2v_cast_5FAF8(result_mant)};
	end
	initial _sv2v_0 = 0;
endmodule
module fp_mul (
	op_a_i,
	op_b_i,
	result_o
);
	reg _sv2v_0;
	localparam tiny_nn_pkg_FPExpWidth = 8;
	localparam tiny_nn_pkg_FPMantWidth = 7;
	input wire [15:0] op_a_i;
	input wire [15:0] op_b_i;
	output reg [15:0] result_o;
	wire [tiny_nn_pkg_FPMantWidth:0] op_a_full_mant;
	wire [tiny_nn_pkg_FPMantWidth:0] op_b_full_mant;
	wire [15:0] mant_mul;
	wire [tiny_nn_pkg_FPExpWidth:0] exp_add;
	wire [tiny_nn_pkg_FPExpWidth:0] exp_add_raw;
	wire [6:0] result_mant;
	wire [7:0] result_exp;
	wire result_sgn;
	wire shift_output_mant;
	assign op_a_full_mant = {1'b1, op_a_i[6-:tiny_nn_pkg_FPMantWidth]};
	assign op_b_full_mant = {1'b1, op_b_i[6-:tiny_nn_pkg_FPMantWidth]};
	assign mant_mul = op_a_full_mant * op_b_full_mant;
	assign exp_add_raw = (op_a_i[14-:8] + op_b_i[14-:8]) + (shift_output_mant ? {{tiny_nn_pkg_FPExpWidth {1'b0}}, 1'b1} : {9 {1'sb0}});
	assign exp_add = exp_add_raw - {2'b00, {7 {1'b1}}};
	assign shift_output_mant = mant_mul[15];
	assign result_mant = (shift_output_mant ? mant_mul[14:8] : mant_mul[13:tiny_nn_pkg_FPMantWidth]);
	assign result_exp = exp_add[7:0];
	assign result_sgn = op_a_i[15] ^ op_b_i[15];
	function automatic [7:0] sv2v_cast_47BAE;
		input reg [7:0] inp;
		sv2v_cast_47BAE = inp;
	endfunction
	function automatic [6:0] sv2v_cast_53328;
		input reg [6:0] inp;
		sv2v_cast_53328 = inp;
	endfunction
	localparam [15:0] tiny_nn_pkg_FPNegInf = {1'b1, sv2v_cast_47BAE(1'sb1), sv2v_cast_53328(1'sb0)};
	localparam [15:0] tiny_nn_pkg_FPPosInf = {1'b0, sv2v_cast_47BAE(1'sb1), sv2v_cast_53328(1'sb0)};
	localparam [15:0] tiny_nn_pkg_FPStdNaN = {1'b1, sv2v_cast_47BAE(1'sb1), sv2v_cast_53328(1'sb1)};
	localparam [15:0] tiny_nn_pkg_FPZero = {1'b0, sv2v_cast_47BAE(1'sb0), sv2v_cast_53328(1'sb0)};
	function tiny_nn_pkg_is_inf;
		input reg [15:0] x;
		tiny_nn_pkg_is_inf = (x == tiny_nn_pkg_FPPosInf) || (x == tiny_nn_pkg_FPNegInf);
	endfunction
	function tiny_nn_pkg_is_nan;
		input reg [15:0] x;
		if (x[14-:8] == {8 {1'sb0}}) begin
			if (x[6-:tiny_nn_pkg_FPMantWidth] != {7 {1'sb0}})
				tiny_nn_pkg_is_nan = 1'b1;
			else if (x[15] == 1'b1)
				tiny_nn_pkg_is_nan = 1'b1;
			else
				tiny_nn_pkg_is_nan = 1'b0;
		end
		else if (x[14-:8] == {8 {1'sb1}}) begin
			if (x[6-:tiny_nn_pkg_FPMantWidth] != {7 {1'sb0}})
				tiny_nn_pkg_is_nan = 1'b1;
			else
				tiny_nn_pkg_is_nan = 1'b0;
		end
		else
			tiny_nn_pkg_is_nan = 1'b0;
	endfunction
	function automatic [7:0] sv2v_cast_76516;
		input reg [7:0] inp;
		sv2v_cast_76516 = inp;
	endfunction
	function automatic [6:0] sv2v_cast_5FAF8;
		input reg [6:0] inp;
		sv2v_cast_5FAF8 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		result_o = tiny_nn_pkg_FPStdNaN;
		if (tiny_nn_pkg_is_nan(op_a_i) || tiny_nn_pkg_is_nan(op_b_i))
			result_o = tiny_nn_pkg_FPStdNaN;
		else if ((op_a_i == tiny_nn_pkg_FPZero) || (op_b_i == tiny_nn_pkg_FPZero))
			result_o = tiny_nn_pkg_FPZero;
		else if (tiny_nn_pkg_is_inf(op_a_i) || tiny_nn_pkg_is_inf(op_b_i))
			result_o = (result_sgn ? tiny_nn_pkg_FPNegInf : tiny_nn_pkg_FPPosInf);
		else if (exp_add_raw <= {2'b00, {7 {1'b1}}})
			result_o = tiny_nn_pkg_FPZero;
		else if (exp_add >= {1'b0, {tiny_nn_pkg_FPExpWidth {1'b1}}})
			result_o = (result_sgn ? tiny_nn_pkg_FPNegInf : tiny_nn_pkg_FPPosInf);
		else
			result_o = {result_sgn, sv2v_cast_76516(result_exp), sv2v_cast_5FAF8(result_mant)};
	end
	initial _sv2v_0 = 0;
endmodule
module tiny_nn_core (
	clk_i,
	rst_ni,
	val_i,
	val_shift_i,
	param_i,
	param_write_i,
	mul_row_sel_i,
	mul_en_i,
	accumulate_loopback_i,
	accumulate_out_relu_i,
	accumulate_level_1_direct_din_i,
	accumulate_level_1_direct_en_i,
	accumulate_en_i,
	accumulate_o
);
	reg _sv2v_0;
	parameter [31:0] ValArrayWidth = 4;
	parameter [31:0] ValArrayHeight = 2;
	input clk_i;
	input rst_ni;
	localparam tiny_nn_pkg_FPExpWidth = 8;
	localparam tiny_nn_pkg_FPMantWidth = 7;
	input wire [15:0] val_i;
	input wire [ValArrayHeight - 1:0] val_shift_i;
	input wire [15:0] param_i;
	input wire [(ValArrayHeight * ValArrayWidth) - 1:0] param_write_i;
	input wire mul_row_sel_i;
	input wire mul_en_i;
	input wire accumulate_loopback_i;
	input wire accumulate_out_relu_i;
	input wire [15:0] accumulate_level_1_direct_din_i;
	input [ValArrayHeight - 1:0] accumulate_level_1_direct_en_i;
	input wire [1:0] accumulate_en_i;
	output wire [15:0] accumulate_o;
	reg [15:0] mul_val_op_q [0:ValArrayWidth - 1][0:ValArrayHeight - 1];
	reg [15:0] param_val_op_q [0:ValArrayWidth - 1][0:ValArrayHeight - 1];
	genvar _gv_y_1;
	generate
		for (_gv_y_1 = 0; _gv_y_1 < ValArrayHeight; _gv_y_1 = _gv_y_1 + 1) begin : genblk1
			localparam y = _gv_y_1;
			genvar _gv_x_1;
			for (_gv_x_1 = 0; _gv_x_1 < ValArrayWidth; _gv_x_1 = _gv_x_1 + 1) begin : genblk1
				localparam x = _gv_x_1;
				always @(posedge clk_i)
					if (param_write_i[(x * ValArrayHeight) + y])
						param_val_op_q[x][y] <= param_i;
				if (x == (ValArrayWidth - 1)) begin : genblk1
					always @(posedge clk_i)
						if (val_shift_i[y])
							mul_val_op_q[x][y] <= val_i;
				end
				else begin : genblk1
					always @(posedge clk_i)
						if (val_shift_i[y])
							mul_val_op_q[x][y] <= mul_val_op_q[x + 1][y];
				end
			end
		end
	endgenerate
	wire [15:0] mul_op_a [0:ValArrayWidth - 1];
	wire [15:0] mul_op_b [0:ValArrayWidth - 1];
	wire [15:0] mul_result_d [0:ValArrayWidth - 1];
	reg [15:0] mul_result_q [0:ValArrayWidth - 1];
	genvar _gv_x_2;
	generate
		for (_gv_x_2 = 0; _gv_x_2 < ValArrayWidth; _gv_x_2 = _gv_x_2 + 1) begin : genblk2
			localparam x = _gv_x_2;
			assign mul_op_a[x] = (mul_row_sel_i ? mul_val_op_q[x][0] : mul_val_op_q[x][1]);
			assign mul_op_b[x] = (mul_row_sel_i ? param_val_op_q[x][0] : param_val_op_q[x][1]);
			fp_mul u_mul(
				.op_a_i(mul_op_a[x]),
				.op_b_i(mul_op_b[x]),
				.result_o(mul_result_d[x])
			);
			always @(posedge clk_i)
				if (mul_en_i)
					mul_result_q[x] <= mul_result_d[x];
		end
	endgenerate
	reg [15:0] accumulate_level_0_q [0:(ValArrayWidth / 2) - 1];
	wire [15:0] accumulate_level_0_d [0:(ValArrayWidth / 2) - 1];
	genvar _gv_x_3;
	generate
		for (_gv_x_3 = 0; _gv_x_3 < (ValArrayWidth / 2); _gv_x_3 = _gv_x_3 + 1) begin : g_accumulate_level_0_inner
			localparam x = _gv_x_3;
			fp_add u_add(
				.op_a_i(mul_result_q[x * 2]),
				.op_b_i(mul_result_q[(x * 2) + 1]),
				.result_o(accumulate_level_0_d[x])
			);
			always @(posedge clk_i)
				if (accumulate_en_i[0])
					accumulate_level_0_q[x] <= accumulate_level_0_d[x];
		end
	endgenerate
	wire [15:0] accumulate_level_0_result;
	reg [15:0] accumulate_level_1_q [0:ValArrayHeight - 1];
	wire [15:0] accumulate_level_1_d [0:ValArrayHeight - 1];
	wire [ValArrayHeight - 1:0] accumulate_level_1_en;
	fp_add u_add(
		.op_a_i(accumulate_level_0_q[0]),
		.op_b_i(accumulate_level_0_q[1]),
		.result_o(accumulate_level_0_result)
	);
	genvar _gv_y_2;
	generate
		for (_gv_y_2 = 0; _gv_y_2 < ValArrayHeight; _gv_y_2 = _gv_y_2 + 1) begin : genblk4
			localparam y = _gv_y_2;
			assign accumulate_level_1_en[y] = (accumulate_en_i[0] & (mul_row_sel_i == y)) | accumulate_level_1_direct_en_i[y];
			assign accumulate_level_1_d[y] = (accumulate_level_1_direct_en_i[y] ? accumulate_level_1_direct_din_i : accumulate_level_0_result);
			always @(posedge clk_i)
				if (accumulate_level_1_en[y])
					accumulate_level_1_q[y] <= accumulate_level_1_d[y];
		end
	endgenerate
	reg [15:0] accumulate_final_op_a;
	reg [15:0] accumulate_final_op_b;
	always @(*) begin
		if (_sv2v_0)
			;
		accumulate_final_op_a = accumulate_level_1_q[0];
	end
	reg [15:0] accumulate_final_q;
	always @(*) begin
		if (_sv2v_0)
			;
		accumulate_final_op_b = (accumulate_loopback_i ? accumulate_final_q : accumulate_level_1_q[1]);
	end
	reg [15:0] accumulate_final_d;
	wire [15:0] accumulate_final_result;
	fp_add u_add_accumulate_final(
		.op_a_i(accumulate_final_op_a),
		.op_b_i(accumulate_final_op_b),
		.result_o(accumulate_final_result)
	);
	function automatic [7:0] sv2v_cast_F6E28;
		input reg [7:0] inp;
		sv2v_cast_F6E28 = inp;
	endfunction
	function automatic [6:0] sv2v_cast_F0E0A;
		input reg [6:0] inp;
		sv2v_cast_F0E0A = inp;
	endfunction
	localparam [15:0] tiny_nn_pkg_FPZero = {1'b0, sv2v_cast_F6E28(1'sb0), sv2v_cast_F0E0A(1'sb0)};
	always @(*) begin
		if (_sv2v_0)
			;
		accumulate_final_d = accumulate_final_result;
		if (accumulate_out_relu_i && accumulate_final_result[15])
			accumulate_final_d = tiny_nn_pkg_FPZero;
	end
	always @(posedge clk_i)
		if (accumulate_en_i[1])
			accumulate_final_q <= accumulate_final_d;
	assign accumulate_o = accumulate_final_q;
	initial _sv2v_0 = 0;
endmodule
module tiny_nn_top (
	clk_i,
	rst_ni,
	data_i,
	data_o
);
	reg _sv2v_0;
	parameter [31:0] CountWidth = 8;
	parameter [31:0] ValArrayWidth = 4;
	parameter [31:0] ValArrayHeight = 2;
	input clk_i;
	input rst_ni;
	input wire [15:0] data_i;
	output reg [7:0] data_o;
	localparam [31:0] ValArraySize = ValArrayWidth * ValArrayHeight;
	reg phase_q;
	reg phase_d;
	reg [CountWidth - 1:0] counter_q;
	reg [CountWidth - 1:0] counter_d;
	reg [CountWidth - 1:0] start_count_q;
	reg [CountWidth - 1:0] start_count_d;
	reg [ValArraySize - 1:0] param_write_q;
	reg [ValArraySize - 1:0] param_write_d;
	reg relu_q;
	reg relu_d;
	reg convolve_run;
	reg accumulate_run;
	reg core_result_skid_en;
	reg accumulate_loopback;
	reg accumulate_out_relu;
	reg [1:0] accumulate_level_1_direct_en;
	reg [3:0] state_q;
	reg [3:0] state_d;
	localparam [3:0] tiny_nn_pkg_CmdOpAccumulate = 4'h2;
	localparam [3:0] tiny_nn_pkg_CmdOpConvolve = 4'h1;
	localparam tiny_nn_pkg_FPExpWidth = 8;
	localparam tiny_nn_pkg_FPMantWidth = 7;
	function automatic [7:0] sv2v_cast_6BBDD;
		input reg [7:0] inp;
		sv2v_cast_6BBDD = inp;
	endfunction
	function automatic [6:0] sv2v_cast_EE239;
		input reg [6:0] inp;
		sv2v_cast_EE239 = inp;
	endfunction
	localparam [15:0] tiny_nn_pkg_FPStdNaN = {1'b1, sv2v_cast_6BBDD(1'sb1), sv2v_cast_EE239(1'sb1)};
	function automatic [CountWidth - 1:0] sv2v_cast_8BE2F;
		input reg [CountWidth - 1:0] inp;
		sv2v_cast_8BE2F = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		state_d = state_q;
		counter_d = counter_q;
		start_count_d = start_count_q;
		phase_d = 1'b0;
		param_write_d = param_write_q;
		convolve_run = 1'b0;
		accumulate_run = 1'b0;
		relu_d = relu_q;
		accumulate_loopback = 1'b0;
		accumulate_out_relu = 1'b0;
		core_result_skid_en = 1'b0;
		accumulate_level_1_direct_en = 1'sb0;
		case (state_q)
			4'd0:
				case (data_i[15:12])
					tiny_nn_pkg_CmdOpConvolve: begin
						state_d = 4'd1;
						param_write_d = 1'sb0;
						param_write_d[0] = 1'b1;
					end
					tiny_nn_pkg_CmdOpAccumulate: begin
						start_count_d = data_i[CountWidth - 1:0];
						counter_d = sv2v_cast_8BE2F(1'b1);
						state_d = 4'd4;
						relu_d = data_i[8];
					end
					default:
						;
				endcase
			4'd1:
				if (param_write_q[ValArraySize - 1]) begin
					param_write_d = 1'sb0;
					state_d = 4'd2;
				end
				else
					param_write_d = {param_write_q[ValArraySize - 2:0], 1'b0};
			4'd2, 4'd3: begin
				phase_d = ~phase_q;
				convolve_run = 1'b1;
				if (state_q == 4'd2) begin
					if (data_i == tiny_nn_pkg_FPStdNaN) begin
						state_d = 4'd3;
						counter_d = 8'd4;
					end
				end
				else if (counter_q != {CountWidth {1'sb0}})
					counter_d = counter_q - 1'b1;
				else
					state_d = 4'd0;
			end
			4'd4: begin
				accumulate_level_1_direct_en[1] = 1'b1;
				state_d = 4'd5;
			end
			4'd5: begin
				accumulate_run = 1'b1;
				accumulate_level_1_direct_en[0] = 1'b1;
				if (counter_q == {CountWidth {1'sb0}}) begin
					counter_d = start_count_q;
					core_result_skid_en = 1'b1;
				end
				else begin
					if (counter_q == sv2v_cast_8BE2F(1'b1))
						accumulate_out_relu = relu_q;
					accumulate_loopback = 1'b1;
					counter_d = counter_q - 1'b1;
					if (data_i == tiny_nn_pkg_FPStdNaN)
						state_d = 4'd6;
				end
			end
			4'd6: begin
				core_result_skid_en = 1'b1;
				state_d = 4'd7;
			end
			4'd7: state_d = 4'd0;
			default:
				;
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			state_q <= 4'd0;
		else
			state_q <= state_d;
	always @(posedge clk_i) begin
		counter_q <= counter_d;
		start_count_q <= start_count_d;
		phase_q <= phase_d;
		param_write_q <= param_write_d;
		relu_q <= relu_d;
	end
	wire [ValArrayHeight - 1:0] core_val_shift;
	wire core_mul_row_sel;
	wire core_mul_en;
	wire [1:0] core_accumulate_en;
	wire [15:0] core_accumulate_result;
	reg [7:0] core_result_skid_q;
	wire [15:0] accumulate_level_1_direct_din;
	assign core_val_shift[0] = ~phase_q & convolve_run;
	assign core_val_shift[1] = phase_q & convolve_run;
	assign core_mul_row_sel = phase_q;
	assign core_mul_en = convolve_run;
	assign core_accumulate_en[0] = convolve_run;
	assign core_accumulate_en[1] = (phase_q & convolve_run) | accumulate_run;
	assign accumulate_level_1_direct_din = data_i;
	function automatic [15:0] sv2v_cast_0825D;
		input reg [15:0] inp;
		sv2v_cast_0825D = inp;
	endfunction
	tiny_nn_core #(
		.ValArrayWidth(ValArrayWidth),
		.ValArrayHeight(ValArrayHeight)
	) u_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.val_i(sv2v_cast_0825D(data_i)),
		.val_shift_i(core_val_shift),
		.param_i(sv2v_cast_0825D(data_i)),
		.param_write_i(param_write_q),
		.mul_row_sel_i(core_mul_row_sel),
		.mul_en_i(core_mul_en),
		.accumulate_loopback_i(accumulate_loopback),
		.accumulate_out_relu_i(accumulate_out_relu),
		.accumulate_level_1_direct_din_i(accumulate_level_1_direct_din),
		.accumulate_level_1_direct_en_i(accumulate_level_1_direct_en),
		.accumulate_en_i(core_accumulate_en),
		.accumulate_o(core_accumulate_result)
	);
	always @(posedge clk_i)
		if (core_result_skid_en)
			core_result_skid_q <= core_accumulate_result[15:8];
	always @(*) begin
		if (_sv2v_0)
			;
		data_o = 1'sb1;
		case (state_q)
			4'd2, 4'd3: data_o = (phase_q ? core_accumulate_result[15:8] : core_accumulate_result[7:0]);
			4'd5:
				if (counter_q == {CountWidth {1'sb0}})
					data_o = core_accumulate_result[7:0];
				else
					data_o = core_result_skid_q;
			4'd6: data_o = core_accumulate_result[7:0];
			4'd7: data_o = core_result_skid_q;
			default:
				;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
