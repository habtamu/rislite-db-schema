--table
drop table if exists core.audit CASCADE;
drop table if exists core.requests CASCADE;
drop table if exists core.appointments CASCADE;
drop table if exists core.examtemplog CASCADE;

drop table if exists core.template_pk_counter;
drop table if exists core.templates;
drop table if exists core.checklist_pk_counter;
drop table if exists core.checklists;

--TYPE
drop type if exists core.status  CASCADE;
drop type if exists core.submodalitytype  CASCADE;
drop type if exists core.patienttype  CASCADE;
drop type if exists core.conditions  CASCADE;
drop type if exists core.mobilities  CASCADE;
drop type if exists core.appointmenttype  CASCADE;
drop type if exists core.templatetypes  CASCADE;
drop type if exists core.prevexamtype  CASCADE;

drop type if exists core.examrow CASCADE;
drop type if exists  core.patientexamrow CASCADE;
drop type if exists  core.examresult CASCADE;
drop type if exists  core.patientappointmentresult CASCADE;
drop type if exists  core.logbookresult CASCADE;

drop type if exists  core.reportroomresult CASCADE;
drop type if exists  core.printresult CASCADE;
drop type if exists  core.summary CASCADE;
drop type if exists  core.archivedresult CASCADE;
drop type if exists  core.appointmentresult CASCADE;

--complex types
drop type if exists core.print_info  CASCADE;
drop type if exists core.patient_info  CASCADE;
drop type if exists core.request_form  CASCADE;
drop type if exists core.report_form  CASCADE;

drop function if exists core.template_pk_next() CASCADE;
drop function if exists core.checklist_pk_next() CASCADE;
drop function if exists core.request_audit_trigger() CASCADE;