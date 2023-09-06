--TABLES

drop table if exists lookup.physicians_pk_counter;
drop table if exists lookup.examtypes_pk_counter;
drop table if exists lookup.hospitals_pk_counter;
drop table if exists lookup.hospitals;
drop table if exists lookup.regions;
drop table if exists lookup.subcities;
drop table if exists lookup.modality;
drop table if exists lookup.examinationtypes;
drop table if exists lookup.physicians;

drop function if exists lookup.examtype_pk_next();
drop function if exists lookup.hospital_pk_next();
drop function if exists lookup.physician_pk_next();


create table lookup.regions(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.regions VALUES 
(1,'AA'),
(2,'Afar'),
(3,'Amhara'),
(4,'Benishangul Gumuz'),
(5,'Dire Dawa'),
(6,'Gambella'),
(7,'Harari'),
(8,'Oromia'),
(9,'Somali'),
(10,'SNNPR'),
(11,'Tigray'),
(12,'Other');

create table lookup.subcities(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.subcities VALUES (1,'N/Lafto'),(2,'Addis Ketema'),(3,'Akaki/Kaliti'),(4,'Arada'),(5,'Bole'),(6,'Gulele'),(7,'Kirkos'),(8,'K/Keraniyo'),(9,'Lideta'),(10,'Yeka'),(11,'-');

create table lookup.modality(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.modality VALUES 
(1,'XRAY'), --
(2,'CT-Scan'), --CT-Scan /CT
(3,'Ultrasound'), --Ultrasound / U/S
(4,'MRI'), -- MRI
(5,'Mammography'),--Mammography / MAMMO
(6,'FLU/IVP'),--Fluoroscopy
(7,'Doppler U/S'),
(8,'Interventional radiology');--Interventional radiology;

--hospitals
CREATE TABLE lookup.hospitals_pk_counter
(       
	hospital_pk int2
);
INSERT INTO lookup.hospitals_pk_counter VALUES (0);
CREATE RULE noins_hospitals_pk AS ON INSERT TO lookup.hospitals_pk_counter
DO NOTHING;
CREATE RULE nodel_only_hospitals_pk AS ON DELETE TO lookup.hospitals_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION lookup.hospital_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE lookup.hospitals_pk_counter set hospital_pk = hospital_pk + 1;
     SELECT INTO next_pk hospital_pk from lookup.hospitals_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create TABLE lookup.hospitals(
 id int2 DEFAULT lookup.hospital_pk_next(),
 name text,
 title text,
 subtitle text,
 address text
);
CREATE RULE nodel_hospitals AS ON DELETE TO lookup.hospitals
DO NOTHING;  

---examinationtypes
CREATE TABLE lookup.examtypes_pk_counter
(       
	examtype_pk int2
);
INSERT INTO lookup.examtypes_pk_counter VALUES (0);
CREATE RULE noins_examtypes_pk AS ON INSERT TO lookup.examtypes_pk_counter
DO NOTHING;
CREATE RULE nodel_only_examtypes_pk AS ON DELETE TO lookup.examtypes_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION lookup.examtype_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE lookup.examtypes_pk_counter set examtype_pk = examtype_pk + 1;
     SELECT INTO next_pk examtype_pk from lookup.examtypes_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table lookup.examinationtypes(
	id int2 DEFAULT lookup.examtype_pk_next(), 
  name varchar not null,
  type	smallint,
  isactive boolean DEFAULT true,
  createdby smallint,
	UNIQUE (name,type)
);
CREATE RULE nodel_examtypes AS ON DELETE TO lookup.examinationtypes
DO NOTHING;  

---physicians
CREATE TABLE lookup.physicians_pk_counter
(       
	physician_pk int2
);
INSERT INTO lookup.physicians_pk_counter VALUES (0);
CREATE RULE noins_physician_pk AS ON INSERT TO lookup.physicians_pk_counter
DO NOTHING;
CREATE RULE nodel_only_physician_pk AS ON DELETE TO lookup.physicians_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION lookup.physician_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE lookup.physicians_pk_counter set physician_pk = physician_pk + 1;
     SELECT INTO next_pk physician_pk from lookup.physicians_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table lookup.physicians( 
	id int2 DEFAULT lookup.physician_pk_next(),
  name text,
  phone text,
  department smallint,  
  isactive boolean DEFAULT true,
  createdby smallint
);
CREATE RULE nodel_pyscians AS ON DELETE TO lookup.physicians
DO NOTHING;  

--INDEX
create index examinationtypes_id_idx on lookup.examinationtypes(id);
create index modality_id_idx on lookup.modality(id); 
create index physcian_id_idx on lookup.physicians(id); 

