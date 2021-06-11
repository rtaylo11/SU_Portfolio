/*
	Author: Brian Taylor
	Course: IST 659 M402
	Term: Oct 18
	Title: Youth Basketball Database 
*/

/*
	Starting DROP statements
*/

-- drop the bb_Assessment table
IF OBJECT_ID('bb_Assessment') IS NOT NULL
DROP TABLE bb_Assessment;
GO

-- drop the bb_Player table
IF OBJECT_ID('bb_Player') IS NOT NULL
DROP TABLE bb_Player;
GO

-- drop the bb_Team table
IF OBJECT_ID('bb_Team') IS NOT NULL
DROP TABLE bb_Team;
GO

-- drop the bb_Coach table 
IF OBJECT_ID('bb_Coach') IS NOT NULL
DROP TABLE bb_Coach;
GO

-- drop the bb_CreatePlayerAssessment procedure
IF OBJECT_ID('bb_CreatePlayerAssessment') IS NOT NULL
DROP PROCEDURE bb_CreatePlayerAssessment;
GO

-- drop the bb_CreatePlayerAssessmentPost procedure
IF OBJECT_ID('bb_CreatePlayerAssessmentPost') IS NOT NULL
DROP PROCEDURE bb_CreatePlayerAssessmentPost;
GO

-- drop the bb_CreatPlayerAssessmentLastYear procedure
IF OBJECT_ID('bb_CreatePlayerAssessmentLastYear') IS NOT NULL
DROP PROCEDURE bb_CreatePlayerAssessmentLastYear;
GO

-- drop the bb_CreatePlayerAssessmentLastYearPost procedure
IF OBJECT_ID('bb_CreatePlayerAssessmentLastYearPost') IS NOT NULL
DROP PROCEDURE bb_CreatePlayerAssessmentLastYearPost;
GO

-- drop the AssignPlayerTeam procedure
IF OBJECT_ID('AssignPlayerTeam') IS NOT NULL
DROP PROCEDURE AssignPlayerTeam;
GO

-- drop the bb_PlayerID Lookup function
IF OBJECT_ID('bb_PlayerIDLookup') IS NOT NULL
DROP FUNCTION dbo.bb_PlayerIDLookup;
GO

/* END dropping Tables, procedures, etc. */

/*
	Starting the CREATE TABLE statements
*/

-- creating the bb_Coach table with bb_CoachID, CoachName & YearsCoached
CREATE TABLE bb_Coach (
	-- surrogate primary key
	bb_CoachID int identity,
	-- text of coach's last name
	CoachName varchar(50) NOT NULL,
	-- number of years(seasons) coached basketball
	YearsCoached int default 0,
	-- setting constraints
	CONSTRAINT PK_bb_CoachID PRIMARY KEY (bb_CoachID)
)
GO

-- creating the bb_Team table with bb_TeamID, SeasonYear & CoachID
CREATE TABLE bb_Team (
	--surrogate primary key
	bb_TeamID int identity,
	-- the year designation for the start of the season, this year would be 2018
	SeasonYear int,
	-- the ID of the coach of the team, foreign key to Coach table
	bb_CoachID int NOT NULL,
	-- the ID of the assistant coach of the team
	AsstCoachID int,
	-- Setting constraints
	CONSTRAINT PK_bb_Team PRIMARY KEY (bb_TeamID),
	-- connecting bb_CoachID between Team and Coach tables
	CONSTRAINT FK_bb_Team FOREIGN KEY (bb_CoachID) REFERENCES bb_Coach(bb_CoachID)
)
GO

-- creating the bb_Player table with PlayerID, PlayerName, TeamID, ParentCoach & YearsPlayed
CREATE TABLE bb_Player (
	-- surrogate primary key
	bb_PlayerID int identity,
	-- first name of player only for privacy reasons, not unique
	PlayerName char (20) NOT NULL,
	-- Team number foreign key to Team table
	bb_TeamID int,
	-- Is the parent a coach? 1 (Yes) or 0 (No), default 0
	ParentCoach bit NOT NULL default 0,
	-- Number of years player has played
	YearsPlayed int,
	--Setting constraints on the table
	--Establishing the primary key
	CONSTRAINT PK_bb_Player PRIMARY KEY (bb_PlayerID),
	--Referencing the foreign key from the Team table
	CONSTRAINT FK_bb_Player FOREIGN KEY (bb_TeamID) REFERENCES bb_Team(bb_TeamID)
)
GO

-- creating the bb_Assessment table with bb_SkillsID, Passing, Dribling,
-- Shooting, Layup, Defense, PrePostSeason, SeasonYear & bb_PlayerID
CREATE TABLE bb_Assessment (
	-- surrogate primary key
	bb_SkillsID int identity,
	-- columns for assessed skills, default is 3 on a 1-5 scale, 5 being the best
	-- defaulting all to NULL as the post season evaluation only consists of overall score
	Passing int default NULL,
	Dribling int default NULL,
	Shooting int default NULL,
	Layup int default NULL,
	Defense int default NULL,
	Overall int default NULL,
	-- column designating if the assessment is a pre or post season assessment
	-- pre season is 0, post season is 1
	PrePostSeason bit NOT NULL default 0,
	-- year the season started
	SeasonYear int default YEAR(getdate()),
	-- PlayerID the foreign key to reference the player for which the assessment was made
	bb_PlayerID int,
	-- setting the constraint for the primary key
	CONSTRAINT PK_bb_Assessment PRIMARY KEY (bb_SkillsID),
	-- setting the constraint for the FK to the bb_Player table
	CONSTRAINT FK_bb_PlayerID FOREIGN KEY (bb_PlayerID) REFERENCES bb_Player(bb_PlayerID)
)
GO

/*
	I removed the PlayerAssessment table from the design as it was artificially inserted
	to manage a many-to-many relationship that was miscaracterised from the design stage.
	Many players arent evaluated on many assessments; however, each player is evaluated
	alone on a standard assessment, so each player recieves one assessment at a time.
	After checking further with the stakeholders, each assessment by each coach is compiled
	and averaged to created the scores for the player assesment.  The stakeholder is adimant
	about not replicating the averaging of scores in this database. I mistakenly thought that
	the league kept every coach's evaluation, but they do not and hence, one eval per player.
	This may be an area for future growth.
*/

/* END Creating tables */

/*
	Starting to populate the tables with data
*/

/* BEGIN bb_Coach population */
-- populating the bb_Coach table with CoachName
INSERT INTO bb_Coach (CoachName)
	VALUES ('Taylor'), ('Loving'), ('Stolarz'), ('Kenney'), ('Angle'), ('VanZandt'),
	 ('Beddis'), ('Jones'), ('Litonjua'), ('Stanton'), ('Denson'), ('Estenson'), ('Lang'),
	 ('Hintzen'), ('Christie'), ('Kidwell'), ('Hardin'), ('Stuart'), ('Fore'), ('Copps'),
	 ('Torres'), ('Morehead'), ('Ziegenhagen'), ('Foreman'), ('Roberts'), ('Bart'), ('Smith'),
	 ('Doe')

-- setting YearsCoached for select coaches to 2
UPDATE bb_Coach SET YearsCoached = 2 
WHERE (CoachName = 'Loving' OR CoachName = 'Kenney' OR CoachName = 'Angle'
		OR CoachName = 'Jones' OR CoachName = 'Estenson');
GO

-- setting yearsCoached for select coaches to 1
UPDATE bb_Coach SET YearsCoached = 1 
WHERE (CoachName = 'Litonjua' OR CoachName = 'Beddis' OR CoachName = 'Stolarz');
GO
/* END bb_Coach population */

/* BEGIN bb_Team population */
-- populating the Team table with the last SeasonYear and Coaches
INSERT INTO bb_Team (SeasonYear, bb_CoachID, AsstCoachID)
	VALUES (YEAR(getdate())-1,(SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Torres'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Morehead')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Loving'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Christie')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Angle'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Taylor')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Stolarz'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Hardin')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Kenney'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Estenson')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Denson'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Ziegenhagen')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Foreman'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Roberts')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Bart'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Stuart')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Jones'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Kidwell')),
	(YEAR(getdate())-1, (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Smith'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Doe'))
GO

-- populating the Team table with this SeasonYear and Coaches
INSERT INTO bb_Team (SeasonYear, bb_CoachID, AsstCoachID)
	VALUES (YEAR(getdate()),(SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Taylor'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Stanton')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Loving'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Christie')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Angle'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Copps')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Stolarz'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Hardin')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Kenney'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Estenson')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Denson'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Lang')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'VanZandt'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Hintzen')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Beddis'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Stuart')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Jones'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Kidwell')),
	(YEAR(getdate()), (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Litonjua'),
	 (SELECT bb_CoachID FROM bb_Coach WHERE bb_Coach.CoachName = 'Fore'))
GO
/* END bb_Team population */

/* BEGIN bb_Player population */
-- bb_Player
-- populating the Player table w/ name and YearsPlayed
INSERT INTO bb_Player (PlayerName, YearsPlayed)
	VALUES ('Graham', 2), ('Keegan', 1), ('Jim', 1), ('Finn', 1), ('Augustus', 2),
	('Ethan', 1), ('Bryant', 1), ('Max', 1), ('William', 2), ('Phillip', 0),
	('Issac', 0), ('Dasean', 2), ('Tommy', 1), ('Hudson', 0), ('Owen A', 1),
	('Owen M', 1), ('Finn B', 1), ('Thomas', 0), ('Shane', 0), ('Bennett', 2),
	('Hank', 1), ('Reed', 2), ('Gabriel', 2), ('Thomas S', 1), ('Wyatt', 2),
	('Collin', 2), ('Benton', 1), ('Reid', 2), ('Jay', 0), ('Tate', 2), ('Zack', 1),
	('Gabriel D', 2), ('Charlie', 2), ('William S', 1), ('Charlie K', 1),
	('Will', 1), ('Zachary', 2), ('Willam R', 2), ('Liam', 2), ('Bennett L', 2),
	('Charlie W', 1), ('Nevin', 1), ('Grant', 0), ('Dane', 2), ('Liam C', 2),
	('Andrew', 1), ('Christian', 2), ('Carson', 1), ('Benjamin', 0), ('Keller', 2),
	('John-David', 3), ('Noah', 2), ('Matthew', 1), ('Jameson', 2), ('Jack', 1), ('Callahan', 1),
	('Christian F', 0), ('Jason', 0), ('Daiken', 1), ('Payton', 1), ('Carlos', 1),
	('Paul', 1), ('Landon', 0), ('Mason', 0), ('Owen T', 1), ('Luc', 2), ('Wyatt H',1),
	('Beckett', 0)
GO

-- updates the ParentCoach field
UPDATE bb_Player SET ParentCoach = 1 WHERE
	PlayerName = 'Owen T' OR
	PlayerName = 'John-David' OR
	PlayerName = 'Max' OR
	PlayerName = 'Wyatt' OR
	PlayerName = 'Keller' OR
	PlayerName = 'Charlie K' OR
	PlayerName = 'Noah' OR
	PlayerName = 'Christian' OR
	PlayerName = 'Finn' OR
	PlayerName = 'Hank' OR
	PlayerName = 'Reed' OR
	PlayerName = 'Mason' OR
	PlayerName = 'Landon' OR
	PlayerName = 'Beckett' OR
	PlayerName = 'Andrew' OR
	PlayerName = 'Keegan' OR
	PlayerName = 'Bennett' OR
	PlayerName = 'Benton' OR
	PlayerName = 'Gabriel' OR
	PlayerName = 'Jameson'
GO

-- used to assign players to teams, @season is used to offset team ID from last season
-- in case there are non-returning players
CREATE PROCEDURE AssignPlayerTeam(@season int, @team int, @pname char(20))
AS
BEGIN
	IF @season = 2018
	SET @team = 10 + @team
	UPDATE bb_Player SET bb_TeamID = @team WHERE PlayerName = @pname
END
GO

-- assign players to teams
EXEC AssignPlayerTeam 2018, 1, 'Graham'
EXEC AssignPlayerTeam 2018, 2, 'Keegan'
EXEC AssignPlayerTeam 2018, 3, 'Jim'
EXEC AssignPlayerTeam 2018, 4, 'Finn'
EXEC AssignPlayerTeam 2018, 5, 'Augustus'
EXEC AssignPlayerTeam 2018, 6, 'Ethan'
EXEC AssignPlayerTeam 2018, 7, 'Bryant'
EXEC AssignPlayerTeam 2018, 8, 'Max'
EXEC AssignPlayerTeam 2018, 9, 'William'
EXEC AssignPlayerTeam 2018, 10, 'Phillip'
EXEC AssignPlayerTeam 2018, 1, 'Issac'
EXEC AssignPlayerTeam 2018, 2, 'Dasean'
EXEC AssignPlayerTeam 2018, 3, 'Tommy'
EXEC AssignPlayerTeam 2018, 4, 'Hudson'
EXEC AssignPlayerTeam 2018, 5, 'Owen A'
EXEC AssignPlayerTeam 2018, 6, 'Owen M'
EXEC AssignPlayerTeam 2018, 7, 'Finn B'
EXEC AssignPlayerTeam 2018, 8, 'Thomas'
EXEC AssignPlayerTeam 2018, 9, 'Shane'
EXEC AssignPlayerTeam 2018, 10, 'Bennett'
EXEC AssignPlayerTeam 2018, 1, 'Hank'
EXEC AssignPlayerTeam 2018, 2, 'Reed'
EXEC AssignPlayerTeam 2018, 3, 'Gabriel'
EXEC AssignPlayerTeam 2018, 4, 'Thomas S'
EXEC AssignPlayerTeam 2018, 5, 'Wyatt'
EXEC AssignPlayerTeam 2018, 6, 'Collin'
EXEC AssignPlayerTeam 2018, 7, 'Benton'
EXEC AssignPlayerTeam 2018, 8, 'Reid'
EXEC AssignPlayerTeam 2018, 9, 'Jay'
EXEC AssignPlayerTeam 2018, 10, 'Tate'
EXEC AssignPlayerTeam 2018, 1, 'Zack'
EXEC AssignPlayerTeam 2018, 2, 'Gabriel D'
EXEC AssignPlayerTeam 2018, 3, 'Charlie'
EXEC AssignPlayerTeam 2018, 4, 'William S'
EXEC AssignPlayerTeam 2018, 5, 'Charlie K'
EXEC AssignPlayerTeam 2018, 6, 'Will'
EXEC AssignPlayerTeam 2018, 7, 'Zachary'
EXEC AssignPlayerTeam 2018, 8, 'Willam R'
EXEC AssignPlayerTeam 2018, 9, 'Liam'
EXEC AssignPlayerTeam 2018, 10, 'Bennett L'
EXEC AssignPlayerTeam 2018, 1, 'Charlie W'
EXEC AssignPlayerTeam 2018, 2, 'Nevin'
EXEC AssignPlayerTeam 2018, 3, 'Grant'
EXEC AssignPlayerTeam 2018, 4, 'Dane'
EXEC AssignPlayerTeam 2018, 5, 'Liam C'
EXEC AssignPlayerTeam 2018, 6, 'Andrew'
EXEC AssignPlayerTeam 2018, 7, 'Christian'
EXEC AssignPlayerTeam 2018, 8, 'Carson'
EXEC AssignPlayerTeam 2018, 9, 'Benjamin'
EXEC AssignPlayerTeam 2018, 10, 'Keller'
EXEC AssignPlayerTeam 2018, 1, 'John-David'
EXEC AssignPlayerTeam 2018, 2, 'Noah'
EXEC AssignPlayerTeam 2018, 3, 'Matthew'
EXEC AssignPlayerTeam 2018, 4, 'Jameson'
EXEC AssignPlayerTeam 2018, 5, 'Jack'
EXEC AssignPlayerTeam 2018, 6, 'Callahan'
EXEC AssignPlayerTeam 2018, 7, 'Christian F'
EXEC AssignPlayerTeam 2018, 8, 'Jason'
EXEC AssignPlayerTeam 2018, 9, 'Daiken'
EXEC AssignPlayerTeam 2018, 10, 'Payton'
EXEC AssignPlayerTeam 2018, 1, 'Carlos'
EXEC AssignPlayerTeam 2018, 2, 'Paul'
EXEC AssignPlayerTeam 2018, 3, 'Landon'
EXEC AssignPlayerTeam 2018, 4, 'Mason'
EXEC AssignPlayerTeam 2018, 5, 'Owen T'
EXEC AssignPlayerTeam 2018, 6, 'Luc'
EXEC AssignPlayerTeam 2018, 7, 'Wyatt H'
EXEC AssignPlayerTeam 2018, 8, 'Beckett'
GO

-- assigns what players have coaches as parents
/*UPDATE bb_Player SET ParentCoach = 1
	WHERE PlayerName = 'Owen' OR PlayerName = 'Finn'
GO*/
/* END bb_Player population */

/* BEGIN bb_Assessment population */
-- bb_Assessment
-- populating the Assessment table w/ assessments

-- this function looks up a PlayerID from the PlayerName
CREATE FUNCTION dbo.bb_PlayerIDLookup(@playername char(20))
RETURNS int AS
BEGIN
	DECLARE @returnvalue int
	SELECT @returnvalue = bb_PlayerID FROM bb_Player
	WHERE bb_Player.PlayerName = @playername
	RETURN @returnvalue
END
GO

-- this procedure populates the Assessment table with a current,
-- pre season assessment
CREATE PROCEDURE bb_CreatePlayerAssessment(@playername char(20), @pass int,
				 @dribble int, @shoot int, @lay int, @def int, @over int)
AS
BEGIN
	INSERT INTO bb_Assessment(bb_PlayerID, SeasonYear, Passing, Dribling, Shooting,
	 Layup, Defense, Overall)
	VALUES (dbo.bb_PlayerIDLookup(@playername), YEAR(getdate()), @pass,
	 @dribble, @shoot, @lay, @def, @over)
END
GO

-- this procedure populates the Assessment table with a current,
-- post season assessment
CREATE PROCEDURE bb_CreatePlayerAssessmentPost(@playername char(20), @over int)
AS
BEGIN
	INSERT INTO bb_Assessment(bb_PlayerID, SeasonYear, Overall, PrePostSeason)
	VALUES (dbo.bb_PlayerIDLookup(@playername), YEAR(getdate()), @over, 1)
END
GO

-- this procedure populates the Assessment table with a previous year
-- pre season assessment
CREATE PROCEDURE bb_CreatePlayerAssessmentLastYear(@playername char(20), @pass int, @dribble int,
				 @shoot int, @lay int, @def int, @over int)
AS
BEGIN
	INSERT INTO bb_Assessment(bb_PlayerID, SeasonYear, Passing, Dribling, Shooting,
	 Layup, Defense, Overall)
	VALUES (dbo.bb_PlayerIDLookup(@playername), (YEAR(getdate()) - 1), @pass,
	 @dribble, @shoot, @lay, @def, @over)
END
GO

-- this procedure populates the Assessment table with a previous year
-- post season assessment
CREATE PROCEDURE bb_CreatePlayerAssessmentLastYearPost (@playername char(20)
				, @over int)
AS
BEGIN
	INSERT INTO bb_Assessment(bb_PlayerID, SeasonYear, Overall, PrePostSeason)
	VALUES (dbo.bb_PlayerIDLookup(@playername), (YEAR(getdate())-1), @over, 1)
END
GO

-- populates the Assessment table with the previous year's pre season assessment
-- used SELECT RTRIM(PlayerName) AS Name FROM bb_Player WHERE YearsPlayed > 0
-- to find the players from last year
EXEC bb_CreatePlayerAssessmentLastYear'Graham', 4,5,4,4,5,4
EXEC bb_CreatePlayerAssessmentLastYear'Keegan', 3,3,4,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Jim', 3,4,4,4,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Finn', 2,3,2,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Augustus', 2,2,3,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Ethan', 1,2,1,1,2,1
EXEC bb_CreatePlayerAssessmentLastYear'Bryant', 2,2,2,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Max', 1,2,3,4,3,4
EXEC bb_CreatePlayerAssessmentLastYear'William', 4,5,4,5,4,5
EXEC bb_CreatePlayerAssessmentLastYear'Dasean', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessmentLastYear'Tommy', 3,2,3,3,2,3
EXEC bb_CreatePlayerAssessmentLastYear'Owen A', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Owen M', 3,2,2,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Finn B', 3,3,3,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Bennett', 4,2,3,4,3,4
EXEC bb_CreatePlayerAssessmentLastYear'Hank', 2,3,2,2,3,2
EXEC bb_CreatePlayerAssessmentLastYear'Reed', 4,3,3,4,3,4
EXEC bb_CreatePlayerAssessmentLastYear'Gabriel', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Thomas S', 2,2,2,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Wyatt', 2,3,3,2,2,3
EXEC bb_CreatePlayerAssessmentLastYear'Collin', 2,2,3,2,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Benton', 1,2,1,2,1,1
EXEC bb_CreatePlayerAssessmentLastYear'Reid', 3,2,2,3,3,2
EXEC bb_CreatePlayerAssessmentLastYear'Tate', 3,3,2,2,2,3 
EXEC bb_CreatePlayerAssessmentLastYear'Zack', 2,3,3,2,2,3
EXEC bb_CreatePlayerAssessmentLastYear'Gabriel D', 3,2,4,4,3,4
EXEC bb_CreatePlayerAssessmentLastYear'Charlie', 2,3,4,4,2,3
EXEC bb_CreatePlayerAssessmentLastYear'William S', 3,2,3,3,2,3 
EXEC bb_CreatePlayerAssessmentLastYear'Charlie K', 4,3,4,4,4,4
EXEC bb_CreatePlayerAssessmentLastYear'Will', 3,4,3,3,4,3
EXEC bb_CreatePlayerAssessmentLastYear'Zachary', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessmentLastYear'Willam R', 2,3,3,2,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Liam', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Bennett L', 2,3,3,2,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Charlie W', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Nevin', 3,4,4,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Dane', 3,2,2,2,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Liam C', 2,2,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Andrew', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Christian', 3,2,2,2,4,3
EXEC bb_CreatePlayerAssessmentLastYear'Carson', 2,3,3,4,4,3
EXEC bb_CreatePlayerAssessmentLastYear'Keller', 4,4,3,3,4,4
EXEC bb_CreatePlayerAssessmentLastYear'John-David', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessmentLastYear'Noah', 3,2,2,3,2,3
EXEC bb_CreatePlayerAssessmentLastYear'Matthew', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Jameson', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Jack', 3,2,3,3,2,3
EXEC bb_CreatePlayerAssessmentLastYear'Callahan', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Daiken', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessmentLastYear'Payton', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Carlos', 3,2,3,4,4,3
EXEC bb_CreatePlayerAssessmentLastYear'Paul', 3,2,2,2,3,2
EXEC bb_CreatePlayerAssessmentLastYear'Owen T', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessmentLastYear'Luc', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessmentLastYear'Wyatt H', 3,4,4,3,3,4
GO

-- populates the Assessment table with the previous year's post season assessment
EXEC bb_CreatePlayerAssessmentLastYearPost'Graham', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Keegan', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Jim', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Finn', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Augustus', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Ethan', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Bryant', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Max', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'William', 5
EXEC bb_CreatePlayerAssessmentLastYearPost'Dasean', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Tommy', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Owen A', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Owen M', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Finn B', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Bennett', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Hank', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Reed', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Gabriel', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Thomas S', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Wyatt', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Collin', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Benton', 1
EXEC bb_CreatePlayerAssessmentLastYearPost'Reid', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Tate', 3 
EXEC bb_CreatePlayerAssessmentLastYearPost'Zack', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Gabriel D', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Charlie', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'William S', 3 
EXEC bb_CreatePlayerAssessmentLastYearPost'Charlie K', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Will', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Zachary', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Willam R', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Liam', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Bennett L', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Charlie W', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Nevin', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Dane', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Liam C', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Andrew', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Christian', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Carson', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Keller', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'John-David', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Noah', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Matthew', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Jameson', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Jack', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Callahan', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Daiken', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Payton', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Carlos', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Paul', 2
EXEC bb_CreatePlayerAssessmentLastYearPost'Owen T', 3
EXEC bb_CreatePlayerAssessmentLastYearPost'Luc', 4
EXEC bb_CreatePlayerAssessmentLastYearPost'Wyatt H', 4
GO

-- populates the Assessment table with this year's pre season assessment 
EXEC bb_CreatePlayerAssessment'Graham', 4,4,4,5,4,4
EXEC bb_CreatePlayerAssessment'Keegan', 3,4,4,3,3,4
EXEC bb_CreatePlayerAssessment'Jim', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessment'Finn', 3,3,3,4,4,3
EXEC bb_CreatePlayerAssessment'Augustus', 3,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Ethan', 2,2,3,3,2,3
EXEC bb_CreatePlayerAssessment'Bryant', 1,2,3,2,3,3
EXEC bb_CreatePlayerAssessment'Max', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessment'William', 2,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Phillip', 3,2,2,3,2,2
EXEC bb_CreatePlayerAssessment'Issac', 2,3,2,2,3,2
EXEC bb_CreatePlayerAssessment'Dasean', 3,4,4,3,4,4
EXEC bb_CreatePlayerAssessment'Tommy', 2,2,3,3,3,3
EXEC bb_CreatePlayerAssessment'Hudson', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessment'Owen A', 3,2,3,2,2,3
EXEC bb_CreatePlayerAssessment'Owen M', 3,3,4,3,4,3
EXEC bb_CreatePlayerAssessment'Finn B', 3,4,4,3,4,3
EXEC bb_CreatePlayerAssessment'Thomas', 3,4,3,3,4,3
EXEC bb_CreatePlayerAssessment'Shane', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessment'Bennett', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessment'Hank', 2,3,2,2,3,2
EXEC bb_CreatePlayerAssessment'Reed', 1,1,1,2,2,2
EXEC bb_CreatePlayerAssessment'Gabriel', 2,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Thomas S', 2,1,2,2,2,2
EXEC bb_CreatePlayerAssessment'Wyatt', 3,2,2,3,2,2
EXEC bb_CreatePlayerAssessment'Collin', 3,3,2,3,3,3
EXEC bb_CreatePlayerAssessment'Benton', 3,3,3,3,2,3
EXEC bb_CreatePlayerAssessment'Reid', 3,3,2,2,2,2
EXEC bb_CreatePlayerAssessment'Jay', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessment'Tate', 3,3,3,4,4,4
EXEC bb_CreatePlayerAssessment'Zack', 3,4,3,4,3,4
EXEC bb_CreatePlayerAssessment'Gabriel D', 2,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Charlie', 3,4,3,4,4,4
EXEC bb_CreatePlayerAssessment'William S', 3,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Charlie K', 3,2,3,3,4,4
EXEC bb_CreatePlayerAssessment'Will', 3,2,3,3,4,3
EXEC bb_CreatePlayerAssessment'Zachary',2,2,2,2,2,2
EXEC bb_CreatePlayerAssessment'Willam R', 1,1,2,1,2,1
EXEC bb_CreatePlayerAssessment'Liam', 4,4,4,3,4,4
EXEC bb_CreatePlayerAssessment'Bennett L', 3,3,3,3,3,3
EXEC bb_CreatePlayerAssessment'Charlie W', 2,3,3,2,3,2
EXEC bb_CreatePlayerAssessment'Nevin', 4,4,4,5,4,5
EXEC bb_CreatePlayerAssessment'Grant', 5,5,5,5,5,5
EXEC bb_CreatePlayerAssessment'Dane', 3,4,4,5,4,4
EXEC bb_CreatePlayerAssessment'Liam C', 4,5,5,4,5,4
EXEC bb_CreatePlayerAssessment'Andrew', 3,4,4,5,5,5
EXEC bb_CreatePlayerAssessment'Christian', 4,5,4,5,5,5
EXEC bb_CreatePlayerAssessment'Carson', 3,4,4,3,3,3
EXEC bb_CreatePlayerAssessment'Benjamin', 2,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Keller', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessment'John-David', 4,4,4,4,5,5
EXEC bb_CreatePlayerAssessment'Noah', 3,3,3,4,3,3
EXEC bb_CreatePlayerAssessment'Matthew', 4,4,3,3,3,3
EXEC bb_CreatePlayerAssessment'Jameson', 3,3,3,4,4,3
EXEC bb_CreatePlayerAssessment'Jack', 3,4,3,3,4,3
EXEC bb_CreatePlayerAssessment'Callahan', 4,3,4,4,3,4
EXEC bb_CreatePlayerAssessment'Christian F', 3,2,2,3,2,2
EXEC bb_CreatePlayerAssessment'Jason', 1,1,2,2,1,1
EXEC bb_CreatePlayerAssessment'Daiken', 2,2,3,4,3,3
EXEC bb_CreatePlayerAssessment'Payton', 2,3,2,2,2,2
EXEC bb_CreatePlayerAssessment'Carlos', 3,4,4,3,4,3
EXEC bb_CreatePlayerAssessment'Paul', 2,2,2,2,2,2
EXEC bb_CreatePlayerAssessment'Landon', 2,2,3,3,2,2
EXEC bb_CreatePlayerAssessment'Mason', 4,3,3,2,3,3
EXEC bb_CreatePlayerAssessment'Owen T', 4,4,4,4,4,4
EXEC bb_CreatePlayerAssessment'Luc', 5,5,5,5,5,5
EXEC bb_CreatePlayerAssessment'Wyatt H', 4,5,4,5,5,5
EXEC bb_CreatePlayerAssessment'Beckett', 3,2,1,2,1,2
GO
/* END bb_Assessment population */

SELECT * FROM bb_Assessment
GO
SELECT * FROM bb_Coach
GO
SELECT * FROM bb_Player
GO
SELECT * FROM bb_Team
GO

-- Data question 1, New players players

SELECT
	COUNT(YearsPlayed) AS NewPlayers
	, YearsPlayed
	FROM bb_Player
	GROUP BY YearsPlayed
	ORDER BY YearsPlayed
GO

-- Data Question 2, are players improving

SELECT bb_Player.PlayerName
	, bb_Assessment.bb_SkillsID AS EvalNumber
	, bb_Assessment.Overall
	FROM bb_Player
	INNER JOIN bb_Assessment ON bb_Player.bb_PlayerID = bb_Assessment.bb_PlayerID
	ORDER BY bb_Player.PlayerName, bb_Assessment.bb_SkillsID;
GO

-- Data Question 3, are players improving/regressing and in what areas?

SELECT bb_Player.PlayerName
	, bb_Assessment.SeasonYear
	, bb_Assessment.bb_SkillsID AS EvalNumber
	, bb_Assessment.Overall
	, bb_Assessment.Passing
	, bb_Assessment.Dribling
	, bb_Assessment.Shooting
	, bb_Assessment.Layup
	, bb_Assessment.Defense
	FROM bb_Player
	INNER JOIN bb_Assessment ON bb_Player.bb_PlayerID = bb_Assessment.bb_PlayerID
	ORDER BY bb_Player.PlayerName, bb_Assessment.bb_SkillsID
GO

-- Data Question 4, Coach retention
SELECT bb_Coach.bb_CoachID
	, bb_Team.SeasonYear
	FROM bb_Team
	INNER JOIN bb_Coach ON bb_Team.bb_CoachID = bb_Coach.bb_CoachID
	GROUP BY bb_Coach.bb_CoachID, bb_Team.SeasonYear
GO

-- Data Question 5, stacked team?
SELECT bb_Team.bb_TeamID
	, CAST(AVG(bb_Assessment.Overall) AS DECIMAL(4,2)) AS AvgOfOverall
	FROM ((bb_Player INNER JOIN bb_Assessment ON
		 bb_Player.bb_PlayerID = bb_Assessment.bb_PlayerID)
		 INNER JOIN bb_Team ON
		 (bb_Team.SeasonYear = bb_Assessment.SeasonYear) 
		 AND (bb_Player.bb_TeamID = bb_Team.bb_TeamID))
		 INNER JOIN bb_Coach ON 
		 bb_Team.bb_CoachID = bb_Coach.bb_CoachID
	GROUP BY bb_Team.bb_TeamID
GO
