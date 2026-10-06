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

Create table TEAM ( 
    TeamID int not null IDENTITY(1,1) PRIMARY KEY,
    UniversityName char(100) not null, 
    TeamName char(100) not null,
    constraint PK_Team PRIMARY KEY (TeamID),
    CONSTRAINT UQ_TeamName UNIQUE (TeamName),
);

if object_id('GAME') is not null
    drop table GAME;
if object_id('Stadium') is not null
    drop table Stadium;
if object_id('TEAM') is not null
    drop table TEAM;

create table GAME ( 
    GameID int not null IDENTITY(1,1) PRIMARY KEY,
    GameDate date not null,
    GameTime time not null,
    HomeScore int  null,
    AwayScore int  null,
    HomeTeamID int not null,
    AwayTeamID int not null,
    WinnerTeamID int null,
    StadiumID int not null,
    constraint PK_Game PRIMARY KEY (GameID),
    CONSTRAINT FK_HomeTeam FOREIGN KEY (HomeTeamID) REFERENCES TEAM(TeamID),
    CONSTRAINT FK_AwayTeam FOREIGN KEY (AwayTeamID) REFERENCES TEAM(TeamID
    constraint FK_WinnerTeam FOREIGN KEY (WinnerTeamID) REFERENCES TEAM(TeamID)
    constraint FK_Stadium FOREIGN KEY (StadiumID) REFERENCES Stadium(StadiumID)
    


)

Create table Stadium ( 
    StadiumID int not null IDENTITY(1,1) PRIMARY KEY,
    StadiumName char(100) not null, 
    stadiumState char(100) not null,
    stadiumCity char(100) not null,
    stadiumCapacity int not null,
    typeofField char(100) not null,

    constraint PK_Stadium PRIMARY KEY (StadiumID),
    CONSTRAINT UQ_StadiumName UNIQUE (StadiumName),
    constraint typeofFieldCheck check (typeofField in ('Grass', 'Artificial Turf', 'Hybrid Turf'))
);


