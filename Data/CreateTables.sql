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


create Table player (
    PlayerID int not null IDENTITY(1,1) PRIMARY KEY,
    PlayerName char(100) not null,
    PlayerHeight int not null,
    PlayerWeight int not null,
    PlayerBirthDate date not null,
    constraint PK_Player PRIMARY KEY (PlayerID),
);

create table Coach (
    CoachID int not null IDENTITY(1,1) PRIMARY KEY,
    CoachName char(100) not null,
    CoachBirthDate date not null,
    constraint PK_Coach PRIMARY KEY (CoachID),
);

create table AppUser (
    UserID int not null IDENTITY(1,1) PRIMARY KEY,
    UserFirstName char(100) not null,
    UserLastName char(100) not null,
    UserName char(100) not null,
    UserEmail char(100) not null,
    UserPassword char(100) not null,
    constraint PK_AppUser PRIMARY KEY (UserID),
    CONSTRAINT UQ_UserEmail UNIQUE (UserEmail),
);

create table Position (
    PositionID int not null IDENTITY(1,1) PRIMARY KEY,
    positionName enum('QB', 'RB', 'Defender', 'Returner', 'Kicker', 'Punter') not null,
    constraint PK_Position PRIMARY KEY (PositionID),
    CONSTRAINT UQ_PositionName UNIQUE (positionName),
);

create table Roster ( 
    RosterID int not null IDENTITY(1,1) PRIMARY KEY,
    Year int not null,
    SeasonWins int not null,
    SeasonLosses int not null,
    SeasonTies int not null,
    TeamID int not null,
    constraint PK_Roster PRIMARY KEY (RosterID),
    CONSTRAINT FK_Team FOREIGN KEY (TeamID) REFERENCES TEAM(TeamID
);

create Table WeeklyPredictionResults (
    WeeklyPredictionID int not null IDENTITY(1,1) PRIMARY KEY,
    UserID int not null,
    GameID int not null,
    PredictedWinnerTeamID int not null,
    ActualWinnerTeamID int null,
    PredictionDate date not null,
    constraint PK_WeeklyPredictionResults PRIMARY KEY (PredictionID),
    CONSTRAINT FK_User FOREIGN KEY (UserID) REFERENCES AppUser(UserID),
    CONSTRAINT FK_Game FOREIGN KEY (GameID) REFERENCES GAME(GameID),
    CONSTRAINT FK_PredictedWinnerTeam FOREIGN KEY (PredictedWinnerTeamID) REFERENCES TEAM(TeamID),
    CONSTRAINT FK_ActualWinnerTeam FOREIGN KEY (ActualWinnerTeamID) REFERENCES TEAM(TeamID)
);

create table GamePrediction
(
    GamePredictionID int not null IDENTITY(1,1) PRIMARY KEY,
    UserID int not null,
    GameID int not null,
    PredictedWinnerTeamID int not null,
    PredictionDateTime DATETIME not null,
    constraint PK_GamePrediction PRIMARY KEY (GamePredictionID),
    CONSTRAINT FK_User FOREIGN KEY (UserID) REFERENCES AppUser(UserID),
    CONSTRAINT FK_Game FOREIGN KEY (GameID) REFERENCES GAME(GameID),
    CONSTRAINT FK_PredictedWinnerTeam FOREIGN KEY (PredictedWinnerTeamID) REFERENCES TEAM(TeamID)
);
