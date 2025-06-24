transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/ram.v}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/arm.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/computer_top.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/controller.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/decoder.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/condlogic.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/datapath.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/regfile.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/adder.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/extend.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/flopr.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/flopenr.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/mux2.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/alu.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/shift.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/condcheck.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/adderalu.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/mulalu.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/dmem.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/Decoder_type.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/debouncer.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/seg7.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/imem.sv}

vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/computer_top_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  computer_top_tb

add wave *
view structure
view signals
run -all
