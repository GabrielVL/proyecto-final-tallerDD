transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/arm.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/computer_top.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/controller.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/decoder.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/condlogic.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/datapath.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/regfile.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/adder.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/extend.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/flopenr.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/mux2.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/dmem.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/alu.sv}
vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/imem.sv}

vlog -sv -work work +incdir+D:/Work/2025\ I/Taller\ de\ Diseno\ Digital/proyecto-final-tallerDD {D:/Work/2025 I/Taller de Diseno Digital/proyecto-final-tallerDD/rom_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  rom

add wave *
view structure
view signals
run -all
