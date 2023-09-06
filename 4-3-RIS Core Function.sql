--DROP
drop type if exists core.examrow CASCADE;
drop type if exists core.patientexamrow CASCADE;
drop type if exists core.examresult CASCADE;
drop type if exists core.patientappointmentresult CASCADE;
drop type if exists core.logbookresult CASCADE;
drop type if exists core.appointmentresult CASCADE;
drop type if exists core.reportroomresult CASCADE;
drop type if exists core.printresult CASCADE;
drop type if exists core.summary CASCADE;
drop type if exists core.archivedresult CASCADE;

--TYPE
CREATE TYPE core.examrow AS (
  seqno	smallint,
  patnumber int,
  condition core.conditions,
  status text,
  statusby  smallint,
  statusbyname text,
  -- patient info
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  examdate timestamp without time zone,
  examinationno text,
  modalityid  smallint,  
  ModalityText  text,
  submodality core.submodalitytype,
  examinationtypeText text,
  physician text,
  referalUnit text,
  hospitalid SMALLINT,
  hospitalname text,
  --status
  readingstartAt timestamp without time zone,
  reporteddate timestamp without time zone,
	duration text,
	--PRINT info
	printcount smallint
);
CREATE TYPE core.patientexamrow AS (
  seqno	smallint,
  patnumber int,
  name text,
  condition core.conditions,
  status core.status,
  statusby  smallint,
  statusbyname text,
  -- exam info	
  examdate timestamp without time zone,
  examinationno text,
  modality  text,
  examinationtype text,
  hospital text
);
CREATE TYPE core.examresult AS (
  seqno	smallint,
	patnumber int,
	examdate timestamp without time zone,
  status core.status,
  condition  core.conditions,
	mrn text,
	name text,
	age text,
  sex char(1),
  phone text,
  pattype core.patienttype,
  mobility core.mobilities,

  ExaminationNo text,
  modality smallint,
	modalityText  text,
  submodality core.submodalitytype,
  examinationtype smallint,
  examinationtypeText text,
  Hospital smallint,
  HospitalText text,
  referalUnit SMALLINT,
	referalUnitText text,
  clinicaldata text,
  physician SMALLINT,
  physicianText text,
  phyphone text,
  prevexamno text,
  prevexamtype core.prevexamtype,
  cr numeric(13,2),
  bun numeric(13,2),
  scanimg text,
  StatusBy SMALLINT,
  StatusByText text,
  reportcontent text,
  reporteddate timestamp without time zone
);
create type core.patientappointmentresult AS(
   modality  text,
   examinationtype text,
   AppointedDate timestamp without time zone,
   Days SMALLINT,
   Reason core.appointmenttype
);
CREATE TYPE core.logbookresult AS (
  seqno	smallint,
  patnumber int,
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  examinationno text,
  modalityid smallint,
  modality  text,
  submodality core.submodalitytype,
  examinationtype text,
  --status
  reporteddate timestamp without time zone,
	reportcontent text
);
CREATE TYPE core.appointmentresult AS(
   PatNumber int,
   SeqNo smallint,
   modality  text,
   examinationtype text,
   MRN text,
   Name text,
   Age text ,
   Sex char(1),
   Phone text,
   Region text,
   Subcity  text,
   RegistrationDate timestamp,
   AppointedDate timestamp,
   Days SMALLINT,
   Reason text,
   createdby text
);
CREATE TYPE core.reportroomresult AS (
  seqno	smallint,
  patnumber int,
  condition core.conditions,
  status text,
  statusby  smallint,
  statusbyText text,
  -- patient info
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  examdate timestamp without time zone,
  ExaminationNo text,
  modality smallint,
	modalityText  text,
  submodality core.submodalitytype,
  examinationtype smallint,
  examinationtypeText text,
  Hospital smallint,
  HospitalText text,
  --status
  readingstartAt timestamp without time zone,
  reporteddate timestamp without time zone,
	duration text,
	--PRINT info
	printcount smallint
	
);
CREATE TYPE core.printresult AS (
  examdate timestamp without time zone,
  mrn text,
	name text,
	age text,
  sex char(1),
  phone text,
  
  ExaminationNo text,
  modality smallint,
	modalityText  text,
  examinationtype smallint,
  examinationtypeText text,
  Hospital smallint,
  physicianText text,
  StatusByText text,
  reportcontent text,
  reporteddate timestamp without time zone
);
create type core.summary AS (
  status text,
  name text,
  count int
);
CREATE TYPE core.archivedresult AS (
  seqno	smallint,
  patnumber int,
  condition core.conditions,
  status text,
  statusby  smallint,
	statusbyname text,
  -- patient info
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  examdate timestamp without time zone,
  
  examinationno text,
  modalityid  smallint,  
  modality  text,
  submodality core.submodalitytype,
  examinationtype text,
  hospital smallint,
  --status
  duration text
	
);

-- FUNCTION
create or replace function core.get_reportroomrows(date,date,int,text[],varchar,text[], int)
returns setof core.examrow
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  modno alias for $5;
  stat alias for $6;
  instu alias for $7;

	outreportroom core.examrow;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,examdate, 
(request).modality as modalityid,(request).modality,(request).submodality,(request).examinationtype,(request).examinationno,(request).physician, (request).referalUnit, hospital,
(report).readingstartAt,reporteddate,
date_trunc('hour', age(now(),examdate::timestamp)) as duration,(print).printcount
from core.requests
where deleted_at is null)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examinationno,o.modalityid,m.name as ModalityText,o.submodality,e.name as ExaminationTypeText,
p.name as physician,d.name as referalUnit, o.hospital as hospitalid, h.name as hospitalname,
o.readingstartAt,o.reporteddate,o.duration,o.printcount
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN lookup.hospitals as h on h.id = o.hospital
left JOIN membership.users as u on u.user_id = o.statusby
group by o.seqno,o.patnumber,o.condition,o.status,o.statusby, u.full_name,o.mrn,o.name,o.age,o.sex,o.phone,
o.examdate,o.examinationno,o.modalityid,m.name,o.submodality,e.name,p.name,d.name,o.hospital,h.name,
o.readingstartAt,o.reporteddate,o.duration,o.printcount
having (date_ge(o.examdate::date,fromdate::date) and date_le(o.examdate::date,todate::date))
       AND(o.modalityid = modid OR modid IS NULL)
       AND(o.hospital = instu OR instu IS NULL)
			 AND ((lower(o.examinationno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.submodality::text LIKE ANY (region))
       AND (o.status::text LIKE ANY (stat))
ORDER BY o.status ,o.condition asc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_patientexamrows(int)
returns setof core.patientexamrow as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,examdate,status,"condition",(patient).name,
 (request).examinationno,(request).modality,(request).examinationtype, hospital,statusby
from core.requests
where deleted_at is null and patnumber =$1
 
)
select o.seqno,o.patnumber,o.name,o."condition",o.status,o.statusby,x.full_name as statusbyname, o.examdate,
o.examinationno,m.name as modality,e.name as examinationtype,h.name as hospital

from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
left JOIN lookup.hospitals as h on h.id = o.hospital
LEFT JOIN membership.users as x on x.user_id = o.statusby 
--where  o.patnumber=$1
ORDER BY o.examdate desc;
$$ LANGUAGE SQL;

create or replace function core.get_examby(int,int,int,date)
returns setof core.examresult as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,examdate,status,"condition",(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,(patient).pattype,(patient).mobility,
 (request).examinationno,(request).modality,(request).submodality,(request).examinationtype, hospital, (request).referalUnit, (request).clinicaldata,(request).physician, 
(request).PhyPhone,(request).PrevExamNo,(request).PrevExamType,(request).cr,(request).bun,(request).scanimg,statusby,(report).reportcontent,reporteddate
from core.requests
where deleted_at is null )
select o.seqno,o.patnumber,o.examdate,o.status,o."condition",o.mrn,o.name,o.age,o.sex,o.phone,o.pattype,o.mobility,
o.examinationno,m.id as modality, m.name as modalityText,o.submodality,e.id as examinationtype, e.name as examinationtypeText,h.id as Hospital,h.name as hospitalText,o.referalUnit,u.name as referalUnitText,o.clinicaldata,o.physician,p.name as physicianText,
o.phyphone, o.prevexamno,o.prevexamtype,o.cr,o.bun,o.scanimg,o.statusby,x.full_name as statusbyText, o.reportcontent,o.reporteddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = p.department
left JOIN lookup.hospitals as h on h.id = o.hospital
left JOIN membership.departments as u on u.id = o.referalUnit
LEFT JOIN membership.users as x on x.user_id = o.statusby 
where  o.patnumber=$1 and m.id = $2 and e.id = $3 
AND (date_ge(o.examdate::date,$4::date) and date_le(o.examdate::date,$4::date));
$$ LANGUAGE SQL;


create or replace function core.get_examby(int,int)
returns setof core.examresult as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,examdate,status,"condition",(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,(patient).pattype,(patient).mobility,
 (request).examinationno,(request).modality,(request).submodality,(request).examinationtype, hospital, (request).referalUnit, (request).clinicaldata,(request).physician, 
(request).PhyPhone,(request).PrevExamNo,(request).PrevExamType,(request).cr,(request).bun,(request).scanimg,statusby,(report).reportcontent,reporteddate
from core.requests
where deleted_at is null and patnumber=$1 and seqno = $2)
select o.seqno,o.patnumber,o.examdate,o.status,o."condition",o.mrn,o.name,o.age,o.sex,o.phone,o.pattype,o.mobility,
o.examinationno,m.id as modality, m.name as modalityText,o.submodality,e.id as examinationtype, e.name as examinationtypeText,h.id as Hospital,h.name as hospitalText,o.referalUnit,u.name as referalUnitText,o.clinicaldata,o.physician,p.name as physicianText,
o.phyphone, o.prevexamno,o.prevexamtype,o.cr,o.bun,o.scanimg,o.statusby,x.full_name as statusbyText, o.reportcontent, o.reporteddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = p.department
left JOIN lookup.hospitals as h on h.id = o.hospital
left JOIN membership.departments as u on u.id = o.referalUnit
LEFT JOIN membership.users as x on x.user_id = o.statusby ;
$$ LANGUAGE SQL;


create or replace function core.get_archivedexamby(int,int)
returns setof core.examresult as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,examdate,status,"condition",(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,(patient).pattype,(patient).mobility,
 (request).examinationno,(request).modality,(request).submodality,(request).examinationtype, hospital, (request).referalUnit, (request).clinicaldata,(request).physician, 
(request).PhyPhone,(request).PrevExamNo,(request).PrevExamType,(request).cr,(request).bun,(request).scanimg,statusby,(report).reportcontent,reporteddate
from core.requests
where deleted_at is not null and patnumber=$1 and seqno = $2)
select o.seqno,o.patnumber,o.examdate,o.status,o."condition",o.mrn,o.name,o.age,o.sex,o.phone,o.pattype,o.mobility,
o.examinationno,m.id as modality, m.name as modalityText,o.submodality,e.id as examinationtype, e.name as examinationtypeText,h.id as Hospital,h.name as hospitalText,o.referalUnit,u.name as referalUnitText,o.clinicaldata,o.physician,p.name as physicianText,
o.phyphone, o.prevexamno,o.prevexamtype,o.cr,o.bun,o.scanimg,o.statusby,x.full_name as statusbyText, o.reportcontent, o.reporteddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = p.department
left JOIN lookup.hospitals as h on h.id = o.hospital
left JOIN membership.departments as u on u.id = o.referalUnit
LEFT JOIN membership.users as x on x.user_id = o.statusby ;
$$ LANGUAGE SQL;


create or replace function core.get_patientappointments(int)
returns setof core.patientappointmentresult
as $$
DECLARE 
	patno alias for $1;
  outappoin core.patientappointmentresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outappoin IN
SELECT initcap(m.name) as modality,initcap(e.name) as examinationtype,a.AppointedDate,a.Days,a.Reason
FROM core.appointments as a
left JOIN lookup.modality as m on a.modality = m.id
left JOIN lookup.examinationtypes as e on a.examinationtype = e.id
where (a.PatNumber = patno)
ORDER BY a.AppointedDate desc
	LOOP
		RETURN NEXT outappoin;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--logbook
create or replace function core.get_logbookrows(int,text[],varchar)
returns setof core.logbookresult
as $$
DECLARE 
	modid alias for $1;
  region alias for $2;
  term alias for $3;
  
	outlogbook core.logbookresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outlogbook IN

with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(request).examinationno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,
reporteddate,(report).reportcontent, search
from core.requests
where deleted_at is null and status = 'reported'
)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examinationno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,
o.reporteddate,o.reportcontent,o.search
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id

where (o.modalityid = modid OR modid IS NULL)
			 AND (o.search @@ to_tsquery(term) OR term IS NULL )
			 AND(o.submodality::text LIKE ANY (region))
       
ORDER BY o.reporteddate desc
	LOOP
		RETURN NEXT outlogbook;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--core.get_appointments
create or replace function core.get_appointments(date,int)
returns setof core.appointmentresult
as $$
DECLARE 
	appointat alias for $1;
  moda alias for $2;
	outappoin core.appointmentresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outappoin IN

with cte_appintment as (
SELECT a.PatNumber,a.SeqNo,upper(m.name) as modality,upper(e.name) as examinationtype,a.MRN, a.Name, a.Age, a.Sex,P.Phone, r.name as region, c.name as Subcity,a.RegistrationDate,a.AppointedDate,a.Days,a.Reason, 
u.full_name as createdby
FROM core.appointments as a
left JOIN lookup.modality as m on a.modality = m.id
left JOIN lookup.examinationtypes as e on a.examinationtype = e.id
INNER JOIN core.patients as p on p.PatNumber = a.PatNumber 
INNER JOIN membership.users as u on u.user_id = a.createdby
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 
where (date_ge(a.AppointedDate::date,appointat::date) 
      and date_le(a.AppointedDate::date,appointat::date))
			AND (a.modality = moda OR moda IS NULL)
) 
select a.* from cte_appintment as a
left join core.requests as r on 
 (a.patnumber = r.patnumber) and (a.seqno = r.seqno)


ORDER BY a.RegistrationDate asc
	LOOP
		RETURN NEXT outappoin;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--core.get_reportedlogs
create or replace function core.get_reportedlogs(timestamp without time zone,timestamp without time zone,int,text[],text,text,text[],int)
returns setof core.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  examtype alias for $5;
  modno alias for $6;
  stat alias for $7;
  instu alias for $8;

	outreportroom core.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(request).examinationno,(request).modality,(request).submodality,(request).examinationtype, hospital,
(report).readingstartAt,reporteddate,
 date_trunc('hour', age(reporteddate::timestamp,examdate::timestamp)) as duration,(print).printcount
from core.requests
where deleted_at is null and status='reported'
)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby,initcap(u.full_name) as statusbyText,
o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examinationno,o.modality,m.name as modalityText,
o.submodality,o.examinationtype,e.name as examinationtypeText,o.hospital,h.name as HospitalText,
o.readingstartAt,o.reporteddate,o.duration,o.printcount

from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
left JOIN membership.users as u on u.user_id = o.statusby
left JOIN lookup.hospitals as h on h.id = o.hospital
where (date_ge(o.reporteddate::date,fromdate::date) and date_le(o.reporteddate::date,todate::date))
       AND ((lower(o.examinationno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.modality = modid OR modid IS NULL)
       AND(o.hospital = instu OR instu IS NULL)
       AND(e.name ilike examtype OR examtype IS NULL)
       AND(o.submodality::text LIKE ANY (region))
      AND (o.status::text LIKE ANY (stat))
ORDER BY o.reporteddate desc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


create or replace function core.get_printout(int,int)
returns setof core.printresult as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,examdate,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone, 
(request).examinationno,(request).modality,(request).examinationtype, hospital, (request).physician, 
statusby,(report).reportcontent,reporteddate
from core.requests
where patnumber=$1 and seqno = $2
)
select o.examdate,o.mrn,o.name,o.age,o.sex,o.phone,
o.examinationno,m.id as modality, m.name as modalityText,e.id as examinationtype, e.name as examinationtypeText,o.Hospital,p.name as physicianText,
x.full_name as statusbyText, o.reportcontent, o.reporteddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
LEFT JOIN membership.users as x on x.user_id = o.statusby ;
$$ LANGUAGE SQL;

--get_assignementcountbyuser
CREATE OR REPLACE FUNCTION core.get_assignementcountbyuser(date,date,integer)
    RETURNS SETOF core.summary 
AS $$
DECLARE
  fromdate alias for $1;
  todate alias for $2; 
  uid alias for $3; 
  outsummary core.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN

with cte_order as(
		select r.status as status, r.statusby,r.examdate,U.full_name AS Name
		from core.requests as r 
		LEFT JOIN membership.users as u on u.user_id = r.statusby
		where (U.user_id = uid) and (deleted_at is null) 
    AND (date_ge(r.examdate::date,fromdate::date) and date_le(r.examdate::date,todate::date))
		)
		select status, name, COUNT(*) 
		FROM cte_order 
		GROUP BY rollup(status, Name)
		having name is not null		  

	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--get_pastduedatecases
CREATE OR REPLACE FUNCTION core.get_pastduedatecases(
	integer)
    RETURNS SETOF core.summary 
AS $$
DECLARE
  uid alias for $1; 
  outsummary core.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN
with cte_order as(
			select r.status as status, r.statusby,r.examdate,r.reporteddate , date_part('DAY', now() - r.reporteddate) as Days, U.full_name AS Name
			from core.requests as r 
			LEFT JOIN membership.users as u on u.user_id = r.statusby
			where (U.user_id = uid) and (deleted_at is null) and (status <> 'reported') and date_part('DAY', now() - r.reporteddate) > 0
		)
		select status, name, COUNT(*) 
		FROM cte_order 
		GROUP BY rollup(status, Name)
		having name is not null		  

	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--get_archivedlogs
create or replace function core.get_archivedlogs(int,text[],text,text)
returns setof core.archivedresult
as $$
DECLARE 
	modid alias for $1;
  region alias for $2;
  examtype alias for $3;
  modno alias for $4;
  
	outarchivedrow core.archivedresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outarchivedrow IN


with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,
 (request).examinationno,(request).modality,(request).submodality,(request).examinationtype, hospital,
 date_trunc('day', age(now()::timestamp,examdate::timestamp)) as duration
from core.requests
where deleted_at is not null
order by date_part('DAY', now() - examdate) desc 
)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examinationno,m.id as modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype, o.hospital,
o.duration
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
left JOIN membership.users as u on u.user_id = o.statusby


where ((lower(o.examinationno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(m.id = modid OR modid IS NULL)
       AND(e.name ilike examtype OR examtype IS NULL)
       AND(o.submodality::text LIKE ANY (region))
       
ORDER BY o.examdate  desc
	LOOP
		RETURN NEXT outarchivedrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;
