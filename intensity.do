onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /tb_intensity/tb_clk
add wave -noupdate -radix decimal /tb_intensity/tb_n_rst
add wave -noupdate -radix decimal /tb_intensity/tb_pixelData
add wave -noupdate -radix decimal /tb_intensity/tb_iGrid
add wave -noupdate -radix decimal /tb_intensity/tb_test_case
add wave -noupdate -radix decimal /tb_intensity/r0
add wave -noupdate -radix decimal /tb_intensity/g0
add wave -noupdate -radix decimal /tb_intensity/b0
add wave -noupdate -radix decimal /tb_intensity/I0
add wave -noupdate -radix decimal /tb_intensity/r1
add wave -noupdate -radix decimal /tb_intensity/g1
add wave -noupdate -radix decimal /tb_intensity/b1
add wave -noupdate -radix decimal /tb_intensity/I1
add wave -noupdate -radix decimal /tb_intensity/r2
add wave -noupdate -radix decimal /tb_intensity/g2
add wave -noupdate -radix decimal /tb_intensity/b2
add wave -noupdate -radix decimal /tb_intensity/I2
add wave -noupdate -radix decimal /tb_intensity/r3
add wave -noupdate -radix decimal /tb_intensity/g3
add wave -noupdate -radix decimal /tb_intensity/b3
add wave -noupdate -radix decimal /tb_intensity/I3
add wave -noupdate -radix decimal /tb_intensity/r4
add wave -noupdate -radix decimal /tb_intensity/g4
add wave -noupdate -radix decimal /tb_intensity/b4
add wave -noupdate -radix decimal /tb_intensity/I4
add wave -noupdate -radix decimal /tb_intensity/r5
add wave -noupdate -radix decimal /tb_intensity/g5
add wave -noupdate -radix decimal /tb_intensity/b5
add wave -noupdate -radix decimal /tb_intensity/I5
add wave -noupdate -radix decimal /tb_intensity/r6
add wave -noupdate -radix decimal /tb_intensity/g6
add wave -noupdate -radix decimal /tb_intensity/b6
add wave -noupdate -radix decimal /tb_intensity/I6
add wave -noupdate -radix decimal /tb_intensity/r7
add wave -noupdate -radix decimal /tb_intensity/g7
add wave -noupdate -radix decimal /tb_intensity/b7
add wave -noupdate -radix decimal /tb_intensity/I7
add wave -noupdate -radix decimal /tb_intensity/r8
add wave -noupdate -radix decimal /tb_intensity/g8
add wave -noupdate -radix decimal /tb_intensity/b8
add wave -noupdate -radix decimal /tb_intensity/I8
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23333 ps} 0} {{Cursor 2} {99219 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {105 ns}
