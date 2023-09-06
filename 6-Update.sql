drop type if exists core.appointmentresult CASCADE;
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
   Status text
);
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
SELECT a.PatNumber,a.SeqNo,upper(m.name) as modality,upper(e.name) as examinationtype,a.MRN, a.Name, a.Age, a.Sex,P.Phone, r.name as region, c.name as Subcity,a.RegistrationDate,a.AppointedDate,a.Days
FROM core.appointments as a
left JOIN lookup.modality as m on a.modality = m.id
left JOIN lookup.examinationtypes as e on a.examinationtype = e.id
INNER JOIN core.patients as p on p.PatNumber = a.PatNumber 
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 
where (date_ge(a.AppointedDate::date,appointat::date) 
      and date_le(a.AppointedDate::date,appointat::date))
			AND (a.modality = moda OR moda IS NULL)
) 
select a.*,r.status from cte_appintment as a
left join core.requests as r on 
 (a.patnumber = r.patnumber) and (a.seqno = r.seqno)
ORDER BY a.RegistrationDate asc
	LOOP
		RETURN NEXT outappoin;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


