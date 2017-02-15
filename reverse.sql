drop index reports_report_idx;
drop index reports_attrs_idx;

drop table points;

drop table if exists temp_report_texts;

drop trigger report_tsv_update ON reports;

drop table reports;
drop table gear_names;
drop table expensive_items;
drop table secret_missions;
drop table expenses;
drop table countries;
drop table agents;

drop  DOMAIN currency;

drop table agent_statuses;

--Not sure on the extensions.