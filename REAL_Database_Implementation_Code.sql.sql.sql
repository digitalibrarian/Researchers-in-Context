-- LIS 543: Database Implementation
-- Chlöe Brew, Taylor Hazan, Amanda Mitchel, Fer Palomares Carranco, Jet To

/* Database set up for the project. 
Step 1 CREATE database; 
Step 2 USE database; 
Step 3 GO */

-- CREATE database

CREATE DATABASE "ResearchersInContext";

-- USE database

USE "ResearchersInContext";
GO


/* CREATE the schemas.
We wanted to have multiple schemas in order to manage our large number of entities.
Step 1 CREATE SCHEMA researcher; 
Step 2 add GO;
Step 3 CREATE SCHEMA institution;
Step 4 add GO;
Step 5 CREATE SCHEMA activity;
Step 6 add GO */
  
-- CREATE schemas

CREATE SCHEMA researcher;
GO

CREATE SCHEMA institution;
GO

CREATE SCHEMA activity;
GO

/* CREATE the parent tables.
These are the core entities that we build all of our associative entities off of.
Step 1 CREATE TABLE researcher; 
Step 2 indicate name of schema and table;
Step 3 add column name;
Step 4 data type and character strings of varying length if applicable;
STEP 5 auto generated PKs;
STEP 6 and PKs where relevant
STEP 7 ensure to close section and add ";" */
  
-- creating parent tables

CREATE TABLE researcher.researcher (
ResearcherID INT IDENTITY(1,1) PRIMARY KEY, 
ResearcherOrcidID BIGINT,
ResearcherFirstName VARCHAR (40) NOT NULL, 
ResearcherPreferredFirstName VARCHAR (40), 
ResearcherMiddleName VARCHAR (40),
ResearcherLastName VARCHAR (40) NOT NULL,
ResearcherEmail VARCHAR (40) NOT NULL,
ResearcherWebsite VARCHAR (100)
);

CREATE TABLE researcher.discipline (
Discipline VARCHAR (40) PRIMARY KEY 
);

CREATE TABLE researcher.subdiscipline (
Subdiscipline VARCHAR (40) PRIMARY KEY 
);

CREATE TABLE researcher.subjectarea (
SubjectArea VARCHAR (100) PRIMARY KEY  
);

CREATE TABLE institution.institution (
InstitutionID INT IDENTITY(1,1) PRIMARY KEY, 
InstitutionType VARCHAR (40) NOT NULL, 
InstitutionName VARCHAR (60) NOT NULL, 
City VARCHAR (40) NOT NULL, 
State VARCHAR (40) NOT NULL, 
Country VARCHAR (40) NOT NULL
);

CREATE TABLE activity.journalarticle (
ArticleID INT IDENTITY(1,1) PRIMARY KEY,
ArticleTitle VARCHAR (200) NOT NULL,
ArticleDOI VARCHAR (100)
);

-- importing data for the above tables using the DBeaver Import Wizard --

/* IMPORT INSTRUCTIONS
We manually created our data in a shared spreadsheet, then downloaded the tabs as individual .csv files to import using the DBeaver Import Wizard. 
In the spreadsheet, we added extra rows to indicate data type and any relevant constraints. 
When we downloaded the .csv files, we deleted these rows so that they only had the data we needed to import.
*/

-- first round of child tables (have FKs in parent tables)

/* CREATE the first round of child tables.
These are the child entities that branch off of the initial parent tables. 
Many of them are also parent tables for other associative entities.
Step 1 CREATE TABLE; 
Step 2 indicate name of schema and table;
Step 3 add column name;
Step 4 data type and character strings of varying length if applicable;
STEP 5 auto generated PKs;
STEP 6 and PKs where relevant
STEP 7 ensure to close section and add ";" */

CREATE TABLE researcher.degree (
DegreeID INT IDENTITY(1,1) PRIMARY KEY, 
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID), 
InstitutionID INT NOT NULL
REFERENCES institution.institution(InstitutionID),
GraduationDate DATE, 
DegreeLevel VARCHAR (40) NOT NULL, 
DegreeDiscipline VARCHAR (60) NOT NULL
);

CREATE TABLE researcher.position (
PositionID INT IDENTITY(1,1) PRIMARY KEY, 
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
InstitutionID INT NOT NULL
REFERENCES institution.institution(InstitutionID),
PositionTitle VARCHAR (100) NOT NULL,
PositionType VARCHAR (40) NOT NULL, 
PositionStartDate DATE NOT NULL, 
PositionEndDate DATE
);

CREATE TABLE researcher.funding (
FundingID INT IDENTITY(1,1) PRIMARY KEY, 
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
InstitutionID INT NOT NULL
REFERENCES institution.institution(InstitutionID),
FundingName VARCHAR (100) NOT NULL, 
FundingStartDate DATE NOT NULL, 
FundingEndDate DATE, 
CONSTRAINT chk_start_before_end CHECK (FundingStartDate < FundingEndDate),
FundingAmount MONEY NOT NULL
);

-- We decided to implement CHECKs to ensure that start dates occur before end dates.

CREATE TABLE researcher.membership (
MembershipID INT IDENTITY(1,1) PRIMARY KEY, 
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
InstitutionID INT NOT NULL
REFERENCES institution.institution(InstitutionID),
MembershipName VARCHAR (100),
MembershipPositionTitle VARCHAR (40) NOT NULL,
MembershipStartDate DATE NOT NULL,
MembershipEndDate Date
);

CREATE TABLE researcher.recognition (
RecognitionID INT IDENTITY(1,1) PRIMARY KEY,
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
RecognitionSource INT NOT NULL
REFERENCES institution.institution(InstitutionID),
RecognitionName VARCHAR (100) NOT NULL
);

CREATE TABLE institution.publisher (
PublisherID INT IDENTITY(1,1) PRIMARY KEY,
InstitutionID INT NOT NULL
REFERENCES institution.institution(InstitutionID),
PublisherName VARCHAR (100) NOT NULL
);

CREATE TABLE institution.journal (
JournalID INT IDENTITY(1,1) PRIMARY KEY,
JournalTitle VARCHAR (100) NOT NULL,
JournalOnlineISSN INT,
JournalPrintISSN INT,
PublisherID INT NOT NULL
REFERENCES institution.publisher(PublisherID)
);

CREATE TABLE institution.conference (
ConferenceID INT IDENTITY(1,1) PRIMARY KEY,
ConferenceName VARCHAR (100) NOT NULL,
PrimaryConferenceOrganizer INT NOT NULL
REFERENCES institution.institution(InstitutionID),
ConferenceStartDate DATE NOT NULL,
ConferenceEndDate DATE NOT NULL,
CONSTRAINT chk_start_before_end CHECK (ConferenceStartDate < ConferenceEndDate),
ConferenceLocation VARCHAR (100) NOT NULL
);

-- We decided to implement CHECKs to ensure that start dates occur before end dates.

CREATE TABLE institution.mediapublisher (
MediaPublisherID INT IDENTITY(1,1) PRIMARY KEY,
MediaPublisherName VARCHAR (60) NOT NULL,
MediaPublisherType VARCHAR (40) NOT NULL,
InstitutionID INT 
REFERENCES institution.institution(InstitutionID)
);

CREATE TABLE institution.communitypartner (
CommunityPartnerID INT IDENTITY(1,1) PRIMARY KEY,
InstitutionID INT 
REFERENCES institution.institution(InstitutionID),
CommunityPartnerName VARCHAR (100) NOT NULL,
CommunityPartnerDescription VARCHAR (200)
);

CREATE TABLE activity.book (
BookID INT IDENTITY(1,1) PRIMARY KEY,
BookTitle VARCHAR (100) NOT NULL,
BookPublicationYear DATE NOT NULL,
PublisherID INT NOT NULL
REFERENCES institution.publisher(PublisherID)
);

CREATE TABLE activity.mediaappearance (
MediaAppearanceID INT IDENTITY(1,1) PRIMARY KEY,
MediaPublisherID INT NOT NULL
REFERENCES institution.mediapublisher(MediaPublisherID),
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
MediaAppearanceType VARCHAR (40) NOT NULL,
MediaAppearanceTitle VARCHAR (100) NOT NULL,
MediaAppearanceDate DATE NOT NULL,
MediaAppearanceDescription VARCHAR (200),
MediaAppearanceLink VARCHAR (100)
);

CREATE TABLE activity.communityengagement (
CommunityEngagementID INT IDENTITY(1,1) PRIMARY KEY,
CommunityPartnerID INT 
REFERENCES institution.communitypartner(CommunityPartnerID),
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
CommunityEngagementType VARCHAR (40) NOT NULL,
CommunityEngagementStartDate DATE NOT NULL,
CommunityEngagementEndDate DATE,
CONSTRAINT chk_start_before_end CHECK (CommunityEngagementStartDate < CommunityEngagementEndDate),
CommunityEngagementDescription VARCHAR (200)
);

-- We decided to implement CHECKs to ensure that start dates occur before end dates.

CREATE TABLE activity.conferenceactivity (
ConferenceActivityID INT IDENTITY(1,1) PRIMARY KEY,
ConferenceID INT NOT NULL
REFERENCES institution.conference(ConferenceID),
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
ConferenceActivityType VARCHAR (40) NOT NULL,
ConferenceActivityTitle VARCHAR (100) NOT NULL,
ConferenceActivityDate DATE NOT NULL
);

CREATE TABLE activity.journalpublication (
JournalPublicationID INT IDENTITY(1,1) PRIMARY KEY,
ArticleID INT NOT NULL
REFERENCES activity.journalarticle(ArticleID),
JournalID INT NOT NULL
REFERENCES institution.journal (JournalID),
JournalPublicationIssue INT NOT NULL,
JournalPublicationVolume INT NOT NULL,
JournalPublicationDate DATE NOT NULL
);

-- import data for these tables using DBeaver Import Wizard

/* IMPORT INSTRUCTIONS
We manually created our data in a shared spreadsheet, then downloaded the tabs as individual .csv files to import using the DBeaver Import Wizard. 
In the spreadsheet, we added extra rows to indicate data type and any relevant constraints. 
We did have to populate FK columns using the generated PKs from our parent tables.  
When we downloaded the .csv files, we deleted these rows so that they only had the data we needed to import.
*/

-- third round upload | second round of child tables (FKs in recently-created tables)

/* CREATE the second round of child tables.
These are the child entities that branch off of the first round of child tables. 
Many of them are also parent tables for other associative entities.
Step 1 CREATE TABLE; 
Step 2 indicate name of schema and table;
Step 3 add column name;
Step 4 data type and character strings of varying length if applicable;
STEP 5 auto generated PKs;
STEP 6 and PKs where relevant
STEP 7 ensure to close section and add ";" */

CREATE TABLE researcher.researcharea (
ResearchAreaID INT IDENTITY(1,1) PRIMARY KEY,
Discipline VARCHAR (40) NOT NULL 
REFERENCES researcher.discipline(Discipline),
Subdiscipline VARCHAR (40)
REFERENCES researcher.subdiscipline(Subdiscipline),
SubjectArea VARCHAR (100)
REFERENCES researcher.subjectarea(SubjectArea),
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID)
);

CREATE TABLE researcher.researcharea(
ResearchAreaID INT IDENTITY(1,1) PRIMARY KEY,
Discipline VARCHAR (40) NOT NULL
REFERENCES researcher.discipline(Discipline),
Subdiscipline VARCHAR (40) NULL
REFERENCES researcher.subdiscipline(Subdiscipline),
SubjectArea VARCHAR (100) NULL
REFERENCES researcher.subjectarea(SubjectArea),
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID)
);

CREATE TABLE researcher.course (
InstitutionID INT NOT NULL
REFERENCES institution.institution(InstitutionID),
CourseNumber VARCHAR (10) NOT NULL,
CourseName VARCHAR (100) NOT NULL,
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
CONSTRAINT PKCourse PRIMARY KEY (InstitutionID, CourseNumber)
);

CREATE TABLE activity.researcherbook (
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
BookID INT NOT NULL
REFERENCES activity.book(BookID),
CONSTRAINT PKResearcherBook PRIMARY KEY (ResearcherID, BookID)
);

CREATE TABLE activity.researcherarticle (
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
ArticleID INT NOT NULL
REFERENCES activity.journalarticle(ArticleID),
CONSTRAINT PKResearcherArticle PRIMARY KEY (ResearcherID, ArticleID)
);

CREATE TABLE activity.articlekeyterms (
ArticleID INT NOT NULL
REFERENCES activity.journalarticle(ArticleID),
ArticleKeyTerm VARCHAR (50) NOT NULL,
CONSTRAINT PKArticleKeyTerms PRIMARY KEY (ArticleID, ArticleKeyTerm)
);

CREATE TABLE activity.researcherconferenceactivity (
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
ConferenceActivityID INT NOT NULL
REFERENCES activity.conferenceactivity(ConferenceActivityID),
CONSTRAINT PKResearcherConferenceActivity PRIMARY KEY (ResearcherID, ConferenceActivityID)
);

CREATE TABLE activity.researchermediaappearance (
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
MediaAppearanceID INT NOT NULL
REFERENCES activity.mediaappearance(MediaAppearanceID),
CONSTRAINT PKResearcherMediaAppearance PRIMARY KEY (ResearcherID, MediaAppearanceID)
);

CREATE TABLE activity.researchercommunityengagement (
ResearcherID INT NOT NULL
REFERENCES researcher.researcher(ResearcherID),
CommunityEngagementID INT NOT NULL
REFERENCES activity.communityengagement(CommunityEngagementID),
CONSTRAINT PKResearcherCommunityEngagement PRIMARY KEY (ResearcherID, CommunityEngagementID)
);

CREATE TABLE activity.communitypartnership (
CommunityEngagementID INT NOT NULL
REFERENCES activity.communityengagement(CommunityEngagementID),
CommunityPartnerID INT NOT NULL
REFERENCES institution.communitypartner(CommunityPartnerID),
CONSTRAINT PKCommunityPartnership PRIMARY KEY (CommunityEngagementID, CommunityPartnerID)
);

-- import data using DBeaver Import Wizard

/* IMPORT INSTRUCTIONS
We manually created our data in a shared spreadsheet, then downloaded the tabs as individual .csv files to import using the DBeaver Import Wizard. 
In the spreadsheet, we added extra rows to indicate data type and any relevant constraints. 
We did have to populate FK columns using the generated PKs from our parent tables from the two previous rounds.  
When we downloaded the .csv files, we deleted these rows so that they only had the data we needed to import.
*/

-- fourth round of coding - encryption
/* We decided to encrypt the ResearcherEmail column for basic security reasons.*/

-- Encryption
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'ResearcherIC!';


USE ResearchersInContext;
CREATE CERTIFICATE Certificate_test WITH SUBJECT = 'Protect my data'


CREATE SYMMETRIC KEY MySymmetricKey2
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Certificate_test;


PASSWORD = 'CBTHFPCAMJT!!';

OPEN SYMMETRIC KEY MySymmetricKey2
DECRYPTION BY CERTIFICATE Certificate_test;

ALTER TABLE researcher.researcher 
ADD EncryptedResearcherEmail varbinary (MAX)
;

UPDATE ResearchersInContext.researcher.researcher 
SET EncryptedResearcherEmail = EncryptByKey (Key_GUID('MySymmetricKey2'), ResearcherEmail)
FROM ResearchersInContext.researcher.researcher
;

-- Verification
SELECT ResearcherID, ResearcherFirstName, EncryptedResearcherEmail
FROM researcher.researcher;

SELECT ResearcherID, ResearcherEmail
FROM researcher.researcher r ;

-- Decryption When Querying
SELECT ResearcherID, ResearcherName, 
CONVERT(VARCHAR(40), DecryptByKey(EncryptedResearcherEmail)) AS DecryptedResearcherEmail
FROM researcher.researchers;

CLOSE SYMMETRIC KEY MySymmetricKey;

-- VIEWS are included below

/*The first view allows us to see a table with subset of important information about each institution, specifically the name, type, and location. */

CREATE VIEW [Institution] AS 
SELECT InstitutionName "Institution Name", InstitutionType "Institution Type", City, Country
FROM institution.institution

/*The second view is a table showing the funding recieved by researchers, this includes the funding name, funding institution, amount, start and end date, and the name of the researcher awarded. It could be used by database users to track funding sources and discover new funding streams for research.*/ 

CREATE VIEW "Funding View"
AS
SELECT TOP 15 rf.FundingName "Name of Funding",  ii.InstitutionName "Funding Institution", rf.FundingAmount "Amount", CAST (rf.FundingStartDate AS Date) "Funding Start Date", 
CAST (rf.FundingEndDate AS Date) "Funding End Date", rr.ResearcherLastName "Researcher Last Name", rr.ResearcherFirstName "Researcher First Name"
FROM researcher.funding rf
INNER JOIN Researcher.researcher rr
ON rr.researcherID =rf.researcherID
INNER JOIN institution.institution ii
ON ii.InstitutionID = rf.InstitutionID
GROUP BY rf.ResearcherID, rf.FundingName, ii.InstitutionName, rf.FundingAmount, rf.FundingStartDate, rf.FundingEndDate, rr.ResearcherLastName, rr.ResearcherFirstName
ORDER BY rf.FundingAmount desc;
