-- INSERT
insert into membership.roles(id,name) values(1,'System Admin'),(2,'Radiologist');

insert into membership.users(user_name, full_name, password,user_role,is_administrator) 
values ('admin', 'Administrator',md5('1'),1, true);

-- insert into membership.operations(operation_id,description) values(1,'[Security] Can maintain user permissions?');
-- insert into membership.operations(operation_id,description) values(2,'[Patient] Can edit patient demographic data?');
-- 
-- insert into membership.operations(operation_id,description) values(10,'[Exam] Can add new exam request?');
-- insert into membership.operations(operation_id,description) values(11,'[Exam] Can update existing exam request?');
-- insert into membership.operations(operation_id,description) values(12,'[Exam] Can remove existing exam request?');
-- insert into membership.operations(operation_id,description) values(13,'[Exam] Can preview patient details?');
-- insert into membership.operations(operation_id,description) values(14,'[Exam] Can merge exam request to patient?');
-- insert into membership.operations(operation_id,description) values(15,'[Form] Can write reporting form?');

-- SELECT
select * from membership.users;


