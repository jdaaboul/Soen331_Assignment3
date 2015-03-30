%% Top-level states 
state(dormant). 
state(init). 
state(idle).
state(monitoring).
state(error_diagnosis).
state(safe_shutdown).

%%States under active state 
%%%%init
state(boot_hw). 
state(senchk).
state(tchk).
state(psychk).
state(ready).
%%%%monitoring
state(monidle).
state(regulate_environment).
state(lockdown).
%%%%lockdown
state(prep_vpurge).
state(alt_temp).
state(alt_psy).
state(risk_assess).
state(safe_status).
%%%%error_diagnosis
state(error_rcv).
state(reset_module_data).
state(applicable_rescue).

%%Initial states
initial_state(dormant, null). 
initial_state(boot_hw, init).
initial_state(monidle, monitoring).
initial_state(prep_vpurge, lockdown).
initial_state(error_rcv, error_diagnosis).

%%Superstates
%%%%init
superstate(init, boot_hw). 
superstate(init, senchk). 
superstate(init, tchk). 
superstate(init, psychk). 
superstate(init, ready). 
%%%%monitoring
superstate(monitoring, monidle). 
superstate(monitoring, regulate_environment). 
superstate(monitoring, lockdown). 
%%%%lockdown
superstate(lockdown, prep_vpurge). 
superstate(lockdown, alt_temp). 
superstate(lockdown, alt_psy). 
superstate(lockdown, risk_assess). 
superstate(lockdown, safe_status). 
%%%%error_diagnosis
superstate(error_diagnosis, error_rcv).
superstate(error_diagnosis, reset_module_data).
superstate(error_diagnosis, applicable_rescue).

%% Transitions within the top-level
transition(dormant, init, start, null, load_drivers). 
transition(init, idle, init_ok, null, confirm_drivers). 
transition(init, error_diagnosis, init_crash, null, 'log info; init_error_msg'). 
transition(idle, monitoring, begin_monitoring, null, begin_experiments). 
transition(idle, error_diagnosis, idle_crash, null, idle_err_msg). 
transition(monitoring, error_diagnosis, monitor_crash, 'inlockdown = false', moni_err_msg). 
transition(error_diagnosis, init, retry_init, 'retry =< 3'	, 'retry++'). 
transition(error_diagnosis, safe_shutdown, shutdown, 'retry > 3', idle_error_protocol).
transition(error_diagnosis, idle, idle_rescue, null, moni_err_protocol). 
transition(error_diagnosis, monitoring, moni_rescue, null, graceful_shutdown). 
transition(safe_shutdown, dormant, sleep, null, null).

%% Transition in init
transition(error_rcv, reset_module_data, null, 'error_protocol_def = false', null).
transition(error_rcv, applicable_rescue, null, 'error_protocol_def = true', null).

%% Transition in monitoring
transition(monidle, regulate_environment, no_contagion, null, null).
transition(regulate_environment, monidle, after_100ms, null, null).
transition(regulate_environment, lockdown, contagion_alert, null, 'facility_crit_msg ; inlockdown = true').
transition(lockdown, monidle, purge_succ, null, 'inlockdown = false').

%% Transition in lockdown not sure cuz of the fork
transition(prep_vpurge, alt_temp, initiate_purge, null, lock_doors).
transition(prep_vpurge, alt_psy, initiate_purge, null, lock_doors).
transition(alt_temp, risk_assess, tcyc_comp, null, null).
transition(alt_psy, risk_assess, psicyc_comp, null, null).
transition(risk_assess, prep_vpurge, null, 'risk > 1%', null).
transition(risk_assess, safe_status, null, 'risk =< 1%', unlock_doors).

