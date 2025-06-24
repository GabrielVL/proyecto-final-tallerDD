transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/computer_top.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/debouncer.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/seg7.sv}
vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/imem.sv}

vlog -sv -work work +incdir+C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD {C:/Users/Ayudapls/Documents/GitHub/proyecto-final-tallerDD/tb_computer_top.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_computer_top

add wave *
view structure
view signals
run -all
