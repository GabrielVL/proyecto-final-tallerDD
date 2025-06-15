transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/rom.v}
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
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/condcheck.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/full_subtractor_nb.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/full_adder_nb.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/full_subtractor_1b.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/full_adder_1b.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/multiplier_nb.sv}

vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/arm_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  arm_tb

add wave *
view structure
view signals
run -all
