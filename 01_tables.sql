-- table creation for full example of bestSpa
-- Treating Address as Value Object (Identity Less) and modeled here as JSON Column for simplification
CREATE TABLE treatment
(
    id          integer unique      not null primary key auto_increment,
    name        VARCHAR(60) unique  not null,
    description VARCHAR(120) unique not null,
    hourly_rate decimal(8, 4)       not null
);

CREATE TABLE spa
(
    id       integer unique      not null primary key auto_increment,
    name     VARCHAR(60) unique  not null,
    email    VARCHAR(60) unique  not null,
    overview VARCHAR(120) unique not null
);

CREATE TABLE spa_branch
(
    id             integer unique not null primary key auto_increment,
    branch_address JSON           not null,
    spa_id         integer        not null,
    branch_phone   INT unique     not null,
    main_branch    bool           not null default false,
    open_date      DATE           not null,
    foreign key (spa_id) references spa (id)
);

-- Many-to-Many Relationship between Treatments and Branches
CREATE TABLE branches_available_treatments
(
    id            integer unique not null primary key auto_increment,
    spa_branch_id integer        not null,
    treatment_id  integer        not null,
    foreign key (spa_branch_id) references spa_branch (id),
    foreign key (treatment_id) references treatment (id)
);

-- Modeling Staff Category Column as ENUM for simplification to distinguish rules (if needed in future improvements)
CREATE TABLE staff
(
    id             integer unique                                     not null primary key auto_increment,
    staff_category ENUM ('Administration', 'FrontDesk', 'Specialist') not null,
    staff_address  JSON                                               not null,
    in_branch      integer                                            not null,
    name           VARCHAR(20) unique                                 not null,
    nationality    VARCHAR(20)                                        not null,
    employed_date  DATE                                               not null,
    contact_number INT unique                                         not null,
    foreign key (in_branch) references spa_branch (id)
);

CREATE TABLE customer
(
    id                integer unique     not null primary key auto_increment,
    public_id         INT unique         not null,
    address           JSON               not null,
    name              VARCHAR(30) unique not null,
    nationality       VARCHAR(20)        not null,
    email             VARCHAR(60) unique not null,
    contact_number    INT unique         not null,
    assigned_discount numeric            not null check (assigned_discount between 5 and 65) default 5
);

CREATE TABLE invoice
(
    id             integer unique not null primary key auto_increment,
    customer_id    integer        not null,
    issued_by      integer        not null,
    invoice_number INT unique     not null,
    issued_date    DATETIME       not null,
    total_price    decimal(8, 4) default 0.0,
    foreign key (customer_id) references customer (id),
    foreign key (issued_by) references staff (id)
);

CREATE TABLE invoice_line
(
    id           integer unique not null primary key auto_increment,
    invoice_id   integer        not null,
    treatment_id integer        not null,
    carried_by   integer        not null,
    duration     numeric        not null,
    line_price   decimal(8, 4) default 0.0,
    foreign key (invoice_id) references invoice (id),
    foreign key (treatment_id) references treatment (id),
    foreign key (carried_by) references staff (id)
);

-- Trigger run after each row created and then inserted in an invoice
-- This trigger calculate the total price after applied discount for each entry of invoice
create trigger calculate_total_price
    after insert
    on invoice_line
    for each row
    update invoice
    set total_price := (select total_price + (new.line_price - new.line_price * (customer.assigned_discount) / 100.0)
                        from customer
                        where invoice.customer_id = customer.id)
    where new.invoice_id = invoice.id;

-- Trigger run after each row created and then inserted in an invoice
-- This trigger accumulate t total price of invoice insertion of each entry in invoice
create trigger calculate_line_price
    before insert
    on invoice_line
    for each row set new.line_price := (select new.duration * treatment.hourly_rate
                                        from treatment
                                        where new.treatment_id = treatment.id);


-- insertion raw data for demo purposes
insert into treatment(name, description, hourly_rate)
values ('Hydra Facial', 'balancing skin tone and enhance texture of the skin', 40.0),
       ('Moroccan Bath', ' improve skin elasticity and hydration', 25.0),
       ('Hair Color & Hair Blow Dry', 'One color hair service with blow dry', 60.0),
       ('Hair Strengthening', 'A combination of oils and ingredients to strength your hair', 40.0),
       ('Relax Massage', 'Release all tensions from your muscles and feel relax', 45.0),
       ('Manicure & Pedicure', 'Enjoy a relax session of cleaning and art for your nails', 15.0);

insert into spa(name, email, overview)
values ('bestSpa', 'bestspa@bestspa.com', 'A spa specialized to deliver a beauty');

insert into spa_branch(branch_address, spa_id, branch_phone, main_branch, open_date)
values ('{"street": "AlKhoud street", "city": "AlKhoud", "PO": "132", "state": "MCT"}',
        1, 765983210, True, date('2023-02-01')),
       ('{"street": "AlSeeb street", "city": "AlSeeb", "PO": "121", "state": "MCT"}',
        1, 765983211, false, date('2023-02-01'));

insert into branches_available_treatments(spa_branch_id, treatment_id)
values (1, 1),
       (2, 1),
       (1, 2),
       (2, 2),
       (1, 3),
       (2, 3),
       (1, 4),
       (2, 4),
       (1, 5),
       (2, 5),
       (1, 6),
       (2, 6);

insert into staff (staff_category, staff_address, in_branch, name, nationality, employed_date, contact_number)
values ('Specialist', '{"street": "AlKhoud street", "city": "AlKhoud", "PO": "132", "state": "MCT"}',
        1, 'Mona', 'Moroccan', date('2023-02-01'), 765983212),
       ('Specialist', '{"street": "AlSeeb street", "city": "AlSeeb", "PO": "121", "state": "MCT"}',
        1, 'Hana', 'Filipino', date('2023-02-01'), 765983213),
       ('Specialist', '{"street": "Azaiba street", "city": "Azaiba", "PO": "130", "state": "MCT"}',
        1, 'Najwa', 'Moroccan', date('2023-02-01'), 765983214),
       ('Specialist', '{"street": "AlKhuwair street", "city": "AlKhuwair", "PO": "133", "state": "MCT"}',
        1, 'Katie', 'Filipino', date('2023-02-01'), 765983215),
       ('Administration', '{"street": "Alkhoud street", "city": "Alkhoud", "PO": "132", "state": "MCT"}',
        1, 'Khalid Hamed', 'Omani', date('2023-02-01'), 765983216),
       ('FrontDesk', '{"street": "AlMaabela street", "city": "AlMaabela", "PO": "122", "state": "MCT"}',
        1, 'Malak Saif', 'Omani', date('2023-02-01'), 765983217),
       ('FrontDesk', '{"street": "Muscat street", "city": "Muscat", "PO": "113", "state": "MCT"}',
        1, 'Aisha Mohammed', 'Omani', date('2023-02-01'), 765983218);

INSERT INTO customer(name, public_id, address, nationality, email, contact_number, assigned_discount)
VALUES ('Samira Hamed', 11223344, '{"street": "AlMaabela street", "city": "AlMaabela", "PO": "122", "state": "MCT"}',
        'OMANI', 'samirahamed@samira.com', 765983219, 10),
       ('Maryem Mansoor', 11223345, '{"street": "AlKhuwair street", "city": "AlKhuwair", "PO": "133", "state": "MCT"}',
        'IRAQI', 'maryemmansoor@maryem.com', 765983220, 15),
       ('Fatima Juma', 11223346, '{"street": "Jawharat AlShati street", "city": "AlSarooj", "PO": "134", "state": "MCT"}'
        ,'OMANI', 'fatimajuma@fatima.com', 765983221, 5),
       ('Cathrine John', 11223347, '{"street": "Muscat street", "city": "Muscat", "PO": "113", "state": "MCT"}',
        'British', 'cathrinejohn@cathrine.com', 765983223, 30);

insert into invoice(customer_id, issued_by, invoice_number, issued_date)
VALUES (1, 1, 1010, date('2023-04-02')),
       (1, 1, 1011, date('2023-04-02')),
       (2, 2, 1012, date('2023-04-02')),
       (2, 2, 1013, date('2023-04-02')),
       (3, 1, 1014, date('2023-04-03')),
       (3, 1, 1015, date('2023-04-03')),
       (3, 1, 1016, date('2023-04-03')),
       (4, 2, 1017, date('2023-04-03'));

insert into invoice_line (invoice_id, treatment_id, carried_by, duration)
values (1, 1, 1, 1.0),
       (2, 1, 2, 1.0),
       (2, 2, 1, 0.5),
       (3, 1, 3, 1.0),
       (3, 6, 4, 1.0),
       (4, 4, 4, 1.0),
       (5, 2, 3, 1.0),
       (6, 1, 2, 1.0),
       (6, 2, 3, 1.0),
       (6, 3, 1, 1.0),
       (6, 4, 1, 1.0),
       (7, 6, 2, 1.0),
       (8, 3, 3, 0.5),
       (8, 5, 4, 1.0);

# Show all information about all customers.
SELECT customer.public_id,customer.name, customer.nationality, customer.email,
       customer.contact_number,customer.address, customer.assigned_discount from customer;

# Show the average invoice amount for each customer
SELECT (customer.name) AS 'Customer Name', COUNT(invoice.id) AS 'Invoices Count',
       AVG(invoice.total_price) AS 'Average Invoices Total Price'
from customer, invoice where customer.id=invoice.customer_id
GROUP BY customer_id;

# Show all information about invoices of a given customer (identified by an idCustomer of your choice)
SELECT u.invoice_number as 'Invoice NO', u.total_price as 'Total Price',
       cl.name as 'Customer Name', s.name as 'Issued Staff', u.issued_date as 'Issued Date',
       t.name as 'Treatment Name', il.duration as 'Duration', il.line_price as 'Treatment Price',
       ss.name as 'Performed by Specialist'
FROM invoice_line il
         INNER JOIN invoice u ON il.invoice_id=u.id
         INNER JOIN treatment t ON t.id=il.treatment_id
         INNER JOIN staff ss ON ss.id=il.carried_by
         INNER JOIN customer cl ON cl.id=u.customer_id
         INNER JOIN staff s ON s.id=u.issued_by
WHERE u.customer_id=cl.id and u.issued_by=s.id and cl.id = 3 order by invoice_number;

# Show the invoice number of the invoice which has the highest total. Show also the patient
# (who is owner of this invoice).
SELECT invoice.invoice_number AS 'Invoice NO', c.name AS 'Invoice Owner',
       invoice.total_price AS 'Highest Paid Total Price'
FROM invoice
         join customer c on c.id = invoice.customer_id
ORDER BY invoice.total_price DESC LIMIT 1;

# Show all treatments done by each staff (identified by an idStaff of your choice) -in real world application,
# it is good practice to specify Staff category as well-
SELECT s.name as 'Performed by Specialist', t.name as 'Treatment Name',cl.name as 'Performed for Customer',
       u.issued_date as 'Date', il.duration as 'Duration', il.line_price as 'Treatment Price'
FROM invoice_line il
         INNER JOIN invoice u ON il.invoice_id=u.id
         INNER JOIN treatment t ON t.id=il.treatment_id
         INNER JOIN staff s ON s.id=il.carried_by
         INNER JOIN customer cl ON cl.id=u.customer_id
WHERE u.customer_id=cl.id and s.id = 3 order by u.issued_date;
