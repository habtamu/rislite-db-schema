--DROP
drop type if exists core.patientlogresult CASCADE; 
drop type if exists core.patientresult CASCADE;

drop table if exists core.patientlogs_pk_counter ;
drop table if exists core.patients_pk_counter ;

drop table if exists core.config;
drop table if exists core.patientlogs;
drop table if exists core.patientnames;
drop table if exists core.patients;

drop function if exists core.patient_pk_next();
drop function if exists core.patientlog_pk_next();
drop function if exists core.get_patientlogs(date,date);
drop function if exists core.get_patientscount(text,text,text,text,text,int4);
drop function if exists core.get_patients(int4, int4,text,text,text,text,text,int4);

drop function if exists core.get_appointments(date, int4);
drop function if exists core.get_archivedlogs(int4, _text, text, text);
drop function if exists core.get_assignementcountbyuser(date, date, int4);
drop function if exists core.get_pastduedatecases(int4);
drop function if exists core.get_printout(int4, int4);
drop function if exists core.get_reportedlogs(timestamp, timestamp, int4, _text, text, text, _text, int4);

--TABLES
create table core.config (
   userid SMALLINT PRIMARY KEY,
   body jsonb
);
create table core.patientnames (
   Name  text unique 
);
CREATE TABLE core.patientlogs_pk_counter
(       
	patientlog_pk int8
);
INSERT INTO core.patientlogs_pk_counter VALUES (0);
CREATE RULE noins_patientlog_pk AS ON INSERT TO core.patientlogs_pk_counter
DO NOTHING;
CREATE RULE nodel_only_patientlog_pk AS ON DELETE TO core.patientlogs_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION core.patientlog_pk_next()
returns int8 AS
$$
  DECLARE
   next_pk int8;
	BEGIN
     UPDATE core.patientlogs_pk_counter set patientlog_pk = patientlog_pk + 1;
     SELECT INTO next_pk patientlog_pk from core.patientlogs_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


create table core.patientlogs (
   id int8 DEFAULT core.patientlog_pk_next(),
   RegistrationDate timestamp without time zone NOT NULL default now(),
   PatNumber int not null ,
   SeqNo smallint,
	 CardNo text not null,
	 Name text not null,
   DoB Date,
   Age text,
   Sex char(1),
   IsNew boolean DEFAULT true,
   Phone text,
   regionid smallint,
   subcityid smallint,
   Address text,
   createdby text,
	 modifiedby text,
   deleted_at timestamp without time zone
);
CREATE RULE nodel_patientlogs AS ON DELETE TO core.patientlogs
DO NOTHING;  

CREATE TABLE core.patients_pk_counter
(       
	patient_pk int4
);
INSERT INTO core.patients_pk_counter VALUES (0);
CREATE RULE noins_patient_pk AS ON INSERT TO core.patients_pk_counter
DO NOTHING;
CREATE RULE nodel_only_patient_pk AS ON DELETE TO core.patients_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION core.patient_pk_next()
returns int4 AS
$$
  DECLARE
   next_pk int4;
	BEGIN
     UPDATE core.patients_pk_counter set patient_pk = patient_pk + 1;
     SELECT INTO next_pk patient_pk from core.patients_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


create table core.patients (
   PatNumber int4 DEFAULT core.patient_pk_next(), 
   regHospital SMALLINT,
	 RegistrationDate date not null,
   CardNo text not null,
	 FirstName text not null,
   MiddleName text not null,
   LastName text,
	 Sex char(1) DEFAULT 'M',
	 DoB date,
   Phone text,
	 Address text,
   regionid smallint,
   subcityid smallint,
   status int2 DEFAULT 1, -- 0 Inactive, 1 Active
	 modifiedby text ,
   modifiedat timestamp without time zone NOT NULL default now()
 --created_at timestamp without time zone NOT NULL
 --updated_at timestamp without time zone NOT NULL
);
CREATE RULE nodel_patients AS ON DELETE TO core.patients
DO NOTHING; 
--alter sequence core.patients_PatNumber_seq RESTART WITH 45626;

-- INDEX
CREATE INDEX index_patients_on_Phone ON core.patients USING btree (Phone);
CREATE INDEX index_patients_on_CardNo ON core.patients USING btree (CardNo);
CREATE INDEX index_patients_on_FirstName ON core.patients USING btree (FirstName);
CREATE INDEX index_patients_on_MiddleName ON core.patients USING btree (MiddleName);
CREATE UNIQUE INDEX index_patients_on_id ON core.patients USING btree (PatNumber);


--TYPE
create type core.patientlogresult AS
(
   id int ,
   RegistrationDate timestamp,
   PatNumber int,
   SeqNo SMALLINT,
	 CardNo text,
	 Name text,
   DoB Date,
   Age text,
   Sex char(1),
   IsNew boolean,
   Phone text,
   regionid smallint,
   Region text,
   subcityid smallint,
   Subcity  text,
	 Address text,
   createdby text,
	 modifiedby text
);
create type core.patientresult AS
(
   PatNumber int,
   RegistrationDate date,	 
   CardNo text,
   PatName text,
	 Sex char(1),
	 Age text,
   Phone text,
   Region text,
   Subcity  text,
   address  text,
	 status int2,
	 modifiedby text,
   modifiedat timestamptz
);

create or replace function core.get_patients(int4, int4,text,text,text,text,text,int4)
returns setof core.patientresult
as $$
DECLARE 
	inhowmany alias for $1;
	page alias for $2;
	cno alias for $3;
  pno alias for $4;
  fname alias for $5;
  mname alias for $6;
  lname alias for $7;
	statustype alias for $8;
	outpatient core.patientresult;
BEGIN
SET join_collapse_limit = 1;
FOR outpatient IN
SELECT p.PatNumber,p.RegistrationDate,p.CardNo,  initcap(concat( p.firstname,' ',p.middlename,' ',p.lastname)) as PatName,p.Sex,
replace(replace(replace(replace(replace(replace(age(CURRENT_DATE  , p.dob)::TEXT,' year','Y'),'Ys','Y'),' mons','M'),' mon','M'),' days','D'),' day','D') as age ,
p.Phone,r."name" as Region,  initcap(c."name") as Subcity,initcap(p.Address) as Address, p.status,p.modifiedby,p.modifiedat
FROM core.patients as p
LEFT OUTER JOIN lookup.regions as r on p.regionid = r."id"
LEFT OUTER JOIN lookup.subcities as c on p.subcityid = c."id"
where (p.CardNo ILIKE cno OR cno IS NULL) AND  
      (p.Phone ILIKE pno OR pno IS NULL) AND
			(p.FirstName ILIKE fname OR fname IS NULL) AND
			(p.MiddleName ILIKE mname OR mname IS NULL) AND
			(p.LastName ILIKE lname OR lname IS NULL) AND
            (p.status = statustype)
ORDER BY p.PatNumber desc

			limit inhowmany
			OFFSET page

	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_patientscount(text,text,text,text,text,int4)
returns setof int
as $$
DECLARE 
	cno alias for $1;
  pno alias for $2;
  fname alias for $3;
  mname alias for $4;
  lname alias for $5;
  statustype alias for $6;

	total int;
BEGIN
		SELECT count(*)
		into total
		FROM core.patients	
    where (CardNo ILIKE cno OR cno IS NULL) AND  
      (Phone ILIKE pno OR pno IS NULL) AND
			(FirstName ILIKE fname OR fname IS NULL) AND
			(MiddleName ILIKE mname OR mname IS NULL) AND
			(LastName ILIKE lname OR lname IS NULL) AND
      (status = statustype);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_patientlogs(date,date)
returns setof core.patientlogresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	outpatient core.patientlogresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outpatient IN
SELECT p.id,p.RegistrationDate,p.PatNumber,p.SeqNo,p.CardNo, initcap(p.Name) as Name,p.DoB, p.Age, 
p.Sex,p.IsNew, P.Phone, p.regionid,initcap(r.name) as region, p.subcityid, c.name as Subcity,p.Address,p.createdby,p.modifiedby
FROM core.patientlogs as p
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 
where date_ge(p.RegistrationDate::date,fromdate::date) 
      and date_le(p.RegistrationDate::date,todate::date)
      and p.deleted_at is null
ORDER BY p.Id desc
	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

INSERT INTO "core"."config" ("userid", "body") VALUES ('1', '{"UserId": 1, "AppSetting": {"From": "2017-05-09T00:00:00", "BackupApp": "C:\\Program Files\\PostgreSQL\\10\\bin\\pg_dump.exe", "IpAddress": null, "ValidDays": 0, "BackupPath": "C:\\RIS.Data", "MRNDigitLength": 9, "ShowModalityNo": true}, "UserSetting": {"RowNo": 60, "Interval": 1000, "LogOffAfter": 30, "AutoDraftSave": 30, "DefaultPrinter": "Radpacs", "GenerateCardNo": true, "AmharicCalander": true}}');



