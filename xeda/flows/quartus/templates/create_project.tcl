set design_name           {{design.name}}
set clock_port            {{design.clock_port}}
set clock_period          {{flow.clock_period}}
set top                   {{design.top}}
set tb_top                {{design.tb_top}}

foreach key [array names quartus] {
    puts "${key}=$quartus($key)"
}

package require ::quartus::project

puts "\n===========================( Setting up project and settings )==========================="
project_new ${design_name} -overwrite

set_global_assignment -name NUM_PARALLEL_PROCESSORS {{nthreads}}

set_global_assignment -name DEVICE {{flow.fpga_part}}

set_global_assignment -name TOP_LEVEL_ENTITY ${top}

{% if design.vhdl_std == "08" %}
    set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
{% endif %}

{% for src in design.sources if not src.sim_only and src.type %}
set_global_assignment -name {% if src.type == "verilog" and src.variant == "systemverilog" -%} SYSTEMVERILOG {%- else -%} {{src.type|upper}} {%- endif -%}_FILE {{src.file}}
{% endfor %}

{% for sdc_file in sdc_files %}
set_global_assignment -name SDC_FILE {{sdc_file}}
{% endfor %}

puts "clocks: [get_clocks]"

set_global_assignment -name NUM_PARALLEL_PROCESSORS {{nthreads}}

{% for k,v in project_settings.items() %}
set_global_assignment -name {{k}} {% if v is number -%} {{v}} {%- else -%} "{{v}}" {%- endif %}
{% endfor %}

# export_assignments

project_close