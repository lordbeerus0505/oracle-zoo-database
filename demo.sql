/*
List employees and their information.
*/
SELECT * FROM emp_v;

/*
List employees that are managers.
*/
SELECT last_name
     , first_name
     , emp_type
FROM emp_v
WHERE m_last_name IS NULL;

/*
List employees' phone numbers.
*/
SELECT * FROM emp_phone_v;

/*
List employees' phone numbers where last name starts with 'Ma'.
*/
SELECT * FROM emp_phone_v
WHERE last_name LIKE 'Ma%';

/*
List employee responsibilities for each shift, zone, and responsibility type.
*/
SELECT shift_name
     , zone_name
     , resp_type
     , last_name
     , first_name
FROM resp_v;

/*
List Brian Smith's responsibilities.
*/
SELECT shift_name
     , zone_name
     , resp_type
FROM resp_v
WHERE last_name = 'Smith' AND first_name = 'Brian';

/*
List employees with non-medical responsibilities for the morning shift.
*/
SELECT shift_name
     , zone_name
     , resp_type
     , last_name
     , first_name
FROM resp_v
WHERE shift_name = 'Morning Shift' AND resp_type = 'non-medical';

/*
List animals and their information.
*/
SELECT * FROM anim_v;

/*
List all the monkeys.
*/
SELECT * FROM anim_v
WHERE cat_name = 'Monkey';

/*
List animal amounts by category.
*/
SELECT * FROM anim_amount_v;

/* 
List total amount of animals.
*/
SELECT SUM(amount) As Total
FROM anim_amount_v;

/*
List supplies in stock (a view for this isn't needed).
*/
SELECT * FROM supplies;

/*
List animal daily needs including which employees are responsible for each
need.
*/
SELECT shift_name
     , zone_name
     , resp_type_name
     , anim_name
     , cat_name
     , sup_name
     , sup_amount
     , sup_unit
     , anim_need_note
     , last_name
     , first_name
FROM anim_need_v;

/*
List animal daily non-medical needs for the night shift.
*/
SELECT shift_name
     , zone_name
     , anim_name
     , cat_name
     , sup_name
     , sup_amount
     , sup_unit
     , anim_need_note
     , last_name
     , first_name
FROM anim_need_v
WHERE shift_name = 'Night Shift' AND resp_type_name = 'non-medical';

/*
List daily medical needs.
*/
SELECT shift_name
     , zone_name
     , anim_name
     , cat_name
     , sup_name
     , sup_amount
     , sup_unit
     , anim_need_note
     , last_name
     , first_name
FROM anim_need_v
WHERE resp_type_name = 'medical';

/*
List animal needs that Bill Jenkins is responsible for taking care of
during the afternoon shift.
*/
SELECT zone_name
     , anim_name
     , cat_name
     , sup_name
     , sup_amount
     , sup_unit
     , anim_need_note
FROM anim_need_v
WHERE last_name = 'Jenkins' 
AND first_name = 'Bill' 
AND shift_name = 'Afternoon Shift';

/*
List total daily supply requirements.
*/
SELECT * FROM daily_sup_req_v;

/*
Set total amount of beef in stock to 2 lbs then get a list of daily requirements
that exceed what is currently in stock.
*/
UPDATE supplies
SET total_amount = 2
WHERE sup_name = 'Raw Beef';

SELECT * FROM daily_sup_exc_v;

/*
Let's subtract our total daily needs from our current stock at the end of the
day. First let's set our supply of raw beef back to 600 lbs because the
database will not allow us to run the update_sup procedure if our needs
exceed our supplies.
*/
UPDATE supplies
SET total_amount = 600
WHERE sup_name = 'Raw Beef';

/*
Let's also view the supply amounts before and after the procedure.
*/
SELECT * FROM supplies;
EXEC update_sup;
SELECT * FROM supplies;

/*
View Sheila the Tiger's medical history.
*/
SELECT * FROM med_tick_v
WHERE anim_name = 'Sheila' AND cat_name = 'Tiger';

/*
View all open medical tickets.
*/
SELECT med_tick_id
     , open_date
     , anim_name
     , cat_name
     , open_note
     , open_by_first_name
     , open_by_last_name
FROM med_tick_v
WHERE close_date IS NULL;

/*
Erica Fairline closes Phoebe's medical ticket
If a non-medical staff member tries to close a ticket with their ID,
an error will be raised.
*/
UPDATE medical_tickets
SET close_emp = 3
  , close_date = SYSDATE
  , close_note = 'She has a fever, prescribing Anti-Biotics'
WHERE med_tick_id = 8;

/*
Prescribe Phoebe anti-biotics twice daily.
*/
INSERT INTO anim_needs (anim_id, sup_id, sup_amount, shift_id, anim_need_note)
VALUES (11, 3, 20, 1, 'Must take between 8 AM and 9 AM.
To be given up until 2/17/14.');

INSERT INTO anim_needs (anim_id, sup_id, sup_amount, shift_id, anim_need_note)
VALUES (11, 3, 20, 3, 'Must take between 8 PM and 9 PM.
To be given up until 2/17/14.');

/* 
Check out Phoebe's updated needs.
The employees responsible for these two new needs has been generated based on
the supply type (medical), the shift, and the zone Phoebe is in.
*/
SELECT * FROM anim_need_v
WHERE anim_name = 'Phoebe';

/*
Add a new gorilla named Peter.
*/
INSERT INTO animals (anim_name, cat_id, gender, anim_dob)
VALUES ('Peter', 7, 'm', DATE '2009-04-04');

/* 
View Peter's daily needs. His food needs have been generated by the
anim_after_insert triggers based on the criteria for a gorilla.
His needs can be freely modified and expanded.
The employees responsible for these needs have been generated as well.
*/
SELECT * FROM anim_need_v
WHERE anim_name = 'Peter';

/* 
If we remove the responsibility record for morning shift, south zone, 
non-medical...
*/
DELETE FROM responsibilities
WHERE shift_id = 1 AND zone_id = 2 AND resp_type = 1;

/*
All of the animals needs for the morning shift, south zone, non-medical
will have no employees currently assigned to them.
*/
SELECT anim_name
     , sup_name
     , last_name
     , first_name
FROM anim_need_v
WHERE shift_name = 'Morning Shift'
AND zone_name = 'South Zone'
AND resp_type_name = 'non-medical';

/*
In order to fix this, let's assign Trisha Martens to morning shift, south zone,
non medical.
*/
INSERT INTO responsibilities (emp_id, shift_id, zone_id, resp_type)
VALUES (10, 1, 2, 1);

/* 
Now those animal needs are assigned to Trisha.
*/
SELECT anim_name
     , sup_name
     , last_name
     , first_name
FROM anim_need_v
WHERE shift_name = 'Morning Shift'
AND zone_name = 'South Zone'
AND resp_type_name = 'non-medical';

/* Also it is important to note that medical employees can be assigned
non-medical responsibilities, but an error will be raised if we attempt
to assign medical responsibilities to a non-medical employee.
*/
