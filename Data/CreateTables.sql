CREATE LOGIN NandaSurendra
with password = 'MI$T353Instructor';

CREATE USER NandaSurendra
for login NandaSurendra;

alter role db_owner ADD MEMBER NandaSurendra;

create table testTable ( 
    id INT PRIMARY KEY,
    NAME varchar(100),
    createDate TIMESTAMP -- DEFAULT CURRENT_TIMESTAMP
);