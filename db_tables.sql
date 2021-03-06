create table user_account (
    name varchar(50) not null,
    email varchar(100) primary key,
    password varchar(500) not null,
    postal_code numeric not null
)

create table tasks (
    task_type varchar(50) primary key
)

create table performs (
    email varchar(100),
    task_type varchar(50),
    price numeric,
    task_description varchar,
    foreign key (email) references taskers(email),
    foreign key (task_type) references tasks(task_type),
    primary key (email, task_type)
)

create table taskerAvailableDatetime (
    email varchar(100),
    availableDate date,
    availableTime time,
    foreign key (email) references taskers(email),
    primary key (email, availableDate, availableTime)
)

create table taskers (
    email varchar(100) primary key,
    name varchar(50) not null,
    phone numeric,
    address varchar(200),
    foreign key (email) references user_account (email)
)

CREATE TYPE status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

create table userTaskerTaskPair (
    user_email varchar(100) references user_account(email),
    tasker_email varchar(100) references taskers(email),
    task_type varchar(50) references tasks(task_type),
    tasker varchar(50)
    chosen_date date,
    chosen_time time,
    address varchar(200),
    duration numeric,
    task_details varchar(1000),
    status status,
    primary key (user_email, tasker_email, task_type, chosen_date, chosen_time)
)

CREATE FUNCTION delete_old_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM taskerAvailableDatetime WHERE availableDate < NOW()::date;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trigger_delete_old_rows
    AFTER INSERT ON taskerAvailableDatetime
    EXECUTE PROCEDURE delete_old_rows();


CREATE FUNCTION delete_outdated_requests() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM userTaskerTaskPair WHERE chosen_date < NOW()::date;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trigger_delete_outdated_requests
    AFTER INSERT OR UPDATE ON userTaskerTaskPair
    EXECUTE PROCEDURE delete_outdated_requests();
