-- Run once before the Python loaders.
-- The CollegeFootballData API has no stadium street address and no player
-- date of birth, so these two NOT NULL columns block every Stadium and
-- Player insert. Allow NULL so the rows can load.

alter table Stadium alter column StadiumStreetAddress NVARCHAR(100) NULL;

go

alter table Player alter column PlayerDateOfBirth date NULL;

go
