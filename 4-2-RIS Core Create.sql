--ENUM
CREATE TYPE core.status AS ENUM ('ready for reading', 'reading', 'reported');
CREATE TYPE core.submodalitytype AS ENUM ('', 'head & neck','chest & cardiovascular','body','musculoskeletal', 'spine');
CREATE TYPE core.patienttype AS ENUM ('OPD', 'IPD', 'Emergency');
CREATE TYPE core.conditions AS ENUM ('Critical','Emergency','Stable');
CREATE TYPE core.mobilities AS ENUM ('walking','wheelchair','stretcher','ambulance');
CREATE TYPE core.appointmenttype AS ENUM ('report');
CREATE TYPE core.templatetypes AS ENUM ('Default', 'Custom');
CREATE TYPE core.prevexamtype AS ENUM ('', 'CT', 'MRI','XRAY');

-- Complex  type
CREATE TYPE core.print_info AS (
  printcount smallint,
  lastprintby text,
  lastprintat timestamp without time zone
);
CREATE TYPE core.patient_info AS (
	  mrn text,
	  name text,
	  age varchar,
    sex char( 1),
    phone text,
    region smallint,
    subcity smallint,
    pattype core.patienttype,
    mobility core.mobilities
   
);
CREATE TYPE core.request_form AS (
	modality  smallint,
  submodality core.submodalitytype,
	examinationtype smallint,
  examinationno text,
  referalUnit smallint,
  clinicaldata text, 
  physician smallint,  
  phyphone text,
  prevexamno text, 
  prevexamtype core.prevexamtype, 
  cr numeric(13,2),
  bun numeric(13,2),
  scanimg text
);
CREATE TYPE core.report_form AS (
  readingstartAt timestamp without time zone,
	readingBy smallint,
	reportcontent text,
  scanimgs text[],
  remark text
  
);

--TABLE
create table core.requests (
   examdate timestamp without time zone,
   condition core.conditions,
		reporteddate timestamp without time zone,
	 status core.status, -- RIS Status   
   statusby smallint,
   seqno	smallint not null,
	 patnumber int not null ,
   hospital smallint,
   
   patient core.patient_info, -- patient Info
   request core.request_form, -- Request Form\
   report core.report_form, --Report form
   print core.print_info, -- Print form
   lastopenat timestamp without time zone DEFAULT now(),
   deleted_at timestamp without time zone,
   search tsvector
);

CREATE TABLE core.audit (
	event_time timestamp NOT NULL,
	user_name varchar NOT NULL,
	operation varchar NOT NULL,
	table_name varchar NOT NULL,
	old_row jsonb,
	new_row jsonb
);

CREATE OR REPLACE FUNCTION core.request_audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'INSERT') THEN
INSERT INTO core.audit
VALUES (CURRENT_TIMESTAMP, CURRENT_USER,TG_OP,
TG_TABLE_NAME, null , row_to_json(NEW));
RETURN NEW;
ELSIF (TG_OP = 'UPDATE') THEN
INSERT INTO core.audit
VALUES (CURRENT_TIMESTAMP, CURRENT_USER,TG_OP,
TG_TABLE_NAME, row_to_json(OLD), row_to_json(NEW));
RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER ris_audit_trigger
AFTER UPDATE OR INSERT OR DELETE
ON core.requests
FOR EACH ROW
EXECUTE PROCEDURE core.request_audit_trigger();

create table core.appointments (
   PatNumber int,
   SeqNo smallint,
   modality  smallint,
   examinationtype smallint,
   MRN text,
   Name text,
   Age text ,
   Sex char(1),
   RegistrationDate timestamp without time zone NOT NULL default now(),
   AppointedDate timestamp without time zone NOT NULL,
   Days SMALLINT not null,
   Reason core.appointmenttype,
   createdby smallint,
   deleted_at timestamp without time zone
	 
);
create table core.examtemplog (
   PatNumber int not null ,
   seqno smallint,
	 Name text not null,
   CardNo text not null,
   Sex char(1) not null,
   Age text not null,
   modality  smallint,
   examinationtype smallint,
   Status core.status NOT NULL DEFAULT 'ready for reading'::core.status,
   createdat timestamp without time zone NOT NULL default now(),
   createdby smallint,
   deleted_at timestamp without time zone
);

CREATE TABLE core.template_pk_counter
(       
	template_pk int
);
INSERT INTO core.template_pk_counter VALUES (0);
CREATE RULE noins_template_pk AS ON INSERT TO core.template_pk_counter
DO NOTHING;
CREATE RULE nodel_only_template_pk AS ON DELETE TO core.template_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION core.template_pk_next()
returns int AS
$$
  DECLARE
   next_pk int;
	BEGIN
     UPDATE core.template_pk_counter set template_pk = template_pk + 1;
     SELECT INTO next_pk template_pk from core.template_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


create table core.templates (
   id int DEFAULT core.template_pk_next(),
   name text,
	 modality  smallint,
   submodality core.submodalitytype,
   content text, 
   templatetype core.templatetypes,
   deleted_at timestamp without time zone,
   createdby text
);
CREATE RULE nodel_templates AS ON DELETE TO core.templates
DO NOTHING;  

--checklist

CREATE TABLE core.checklist_pk_counter
(       
	checklist_pk int
);
INSERT INTO core.checklist_pk_counter VALUES (0);
CREATE RULE noins_checklist_pk AS ON INSERT TO core.checklist_pk_counter
DO NOTHING;
CREATE RULE nodel_only_checklist_pk AS ON DELETE TO core.checklist_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION core.checklist_pk_next()
returns int AS
$$
  DECLARE
   next_pk int;
	BEGIN
     UPDATE core.checklist_pk_counter set checklist_pk = checklist_pk + 1;
     SELECT INTO next_pk checklist_pk from core.checklist_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table core.checklists (
   id int DEFAULT core.checklist_pk_next(),
   modality  smallint,
   submodality core.submodalitytype,
   content text, 
   deleted_at timestamp without time zone,
   createdby text
);
CREATE RULE nodel_checklists AS ON DELETE TO core.checklists
DO NOTHING;  

drop view if EXISTS core.reportlog ;
create view core.reportlog 
as
with cte_Log as (
SELECT new_row->'patnumber'::text as patnumber, 
       event_time, 
       new_row->'report'->'reportcontent' as reportcontent,
       new_row->'report'->'readingby'::text as readingby, 
       new_row->'report'->'reportedby'::text as reportedby 
from core.audit  
)
select ROW_NUMBER() OVER w, event_time, patnumber::text,readingby::text,reportedby::text,reportcontent 
from cte_Log
WINDOW w AS ();