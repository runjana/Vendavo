USE [master]
GO

/****** Object:  Database [NBNEjendals]    Script Date: 2019-05-31 10:30:09 ******/
CREATE DATABASE [NBNEjendals]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NBN', FILENAME = N'H:\SQL Data\NBNEjendals1.mdf' , SIZE = 15463040KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB ), 
 FILEGROUP [Archive] 
( NAME = N'NBN_DB2', FILENAME = N'H:\SQL Data\NBNEjendals.mdf' , SIZE = 4386176KB , MAXSIZE = UNLIMITED, FILEGROWTH = 51200KB )
 LOG ON 
( NAME = N'NBN_log', FILENAME = N'E:\Log\NBNEjendals.ldf' , SIZE = 10518464KB , MAXSIZE = 2048GB , FILEGROWTH = 524288KB )
GO

ALTER DATABASE [NBNEjendals] SET COMPATIBILITY_LEVEL = 110
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NBNEjendals].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [NBNEjendals] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [NBNEjendals] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [NBNEjendals] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [NBNEjendals] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [NBNEjendals] SET ARITHABORT OFF 
GO

ALTER DATABASE [NBNEjendals] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [NBNEjendals] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [NBNEjendals] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [NBNEjendals] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [NBNEjendals] SET CURSOR_DEFAULT  LOCAL 
GO

ALTER DATABASE [NBNEjendals] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [NBNEjendals] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [NBNEjendals] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [NBNEjendals] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [NBNEjendals] SET  ENABLE_BROKER 
GO

ALTER DATABASE [NBNEjendals] SET AUTO_UPDATE_STATISTICS_ASYNC ON 
GO

ALTER DATABASE [NBNEjendals] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [NBNEjendals] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [NBNEjendals] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO

ALTER DATABASE [NBNEjendals] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [NBNEjendals] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [NBNEjendals] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [NBNEjendals] SET RECOVERY FULL 
GO

ALTER DATABASE [NBNEjendals] SET  MULTI_USER 
GO

ALTER DATABASE [NBNEjendals] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [NBNEjendals] SET DB_CHAINING OFF 
GO

ALTER DATABASE [NBNEjendals] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [NBNEjendals] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [NBNEjendals] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [NBNEjendals] SET QUERY_STORE = OFF
GO

USE [NBNEjendals]
GO

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO

ALTER DATABASE [NBNEjendals] SET  READ_WRITE 
GO


USE [master]
GO

/****** Object:  Database [NAIS_Ejendals]    Script Date: 2019-05-31 10:31:53 ******/
CREATE DATABASE [NAIS_Ejendals]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NAIS_Ejendals', FILENAME = N'D:\DATA\NAIS_Ejendals.mdf' , SIZE = 9482240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'NAIS_Ejendals_log', FILENAME = N'E:\Log\NAIS_Ejendals_log.ldf' , SIZE = 473984KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [NAIS_Ejendals] SET COMPATIBILITY_LEVEL = 120
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NAIS_Ejendals].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [NAIS_Ejendals] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET ARITHABORT OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [NAIS_Ejendals] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [NAIS_Ejendals] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET  ENABLE_BROKER 
GO

ALTER DATABASE [NAIS_Ejendals] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [NAIS_Ejendals] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [NAIS_Ejendals] SET  MULTI_USER 
GO

ALTER DATABASE [NAIS_Ejendals] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [NAIS_Ejendals] SET DB_CHAINING OFF 
GO

ALTER DATABASE [NAIS_Ejendals] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [NAIS_Ejendals] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [NAIS_Ejendals] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [NAIS_Ejendals] SET QUERY_STORE = OFF
GO

USE [NAIS_Ejendals]
GO

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO

ALTER DATABASE [NAIS_Ejendals] SET  READ_WRITE 
GO


USE [master]
GO

/****** Object:  Database [NAIS_Ejendals_Hist]    Script Date: 2019-05-31 10:31:56 ******/
CREATE DATABASE [NAIS_Ejendals_Hist]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NAIS_Ejendals_Hist', FILENAME = N'D:\DATA\NAIS_Ejendals_Hist.mdf' , SIZE = 2883584KB , MAXSIZE = UNLIMITED, FILEGROWTH = 131072KB )
 LOG ON 
( NAME = N'NAIS_Ejendals_Hist_log', FILENAME = N'E:\Log\NAIS_Ejendals_Hist_1.ldf' , SIZE = 923904KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET COMPATIBILITY_LEVEL = 120
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NAIS_Ejendals_Hist].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET ARITHABORT OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET  DISABLE_BROKER 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET READ_COMMITTED_SNAPSHOT ON 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET  MULTI_USER 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET DB_CHAINING OFF 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET QUERY_STORE = OFF
GO

USE [NAIS_Ejendals_Hist]
GO

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO

ALTER DATABASE [NAIS_Ejendals_Hist] SET  READ_WRITE 
GO

ALTER DATABASE [NAIS_Ejendals] SET RECOVERY FULL WITH NO_WAIT
GO
ALTER DATABASE [NAIS_Ejendals_Hist] SET RECOVERY FULL WITH NO_WAIT
GO
ALTER DATABASE [NBNEjendals] SET RECOVERY FULL WITH NO_WAIT
GO



USE [master]
GO
CREATE LOGIN [NAVETTI\svc_ejendals] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
use [NAIS_Ejendals]

GO
USE [NAIS_Ejendals]
GO
CREATE USER [NAVETTI\svc_ejendals] FOR LOGIN [NAVETTI\svc_ejendals]
GO
USE [NAIS_Ejendals]
GO
ALTER USER [NAVETTI\svc_ejendals] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [NAIS_Ejendals]
GO
ALTER ROLE [db_owner] ADD MEMBER [NAVETTI\svc_ejendals]
GO
use [NAIS_Ejendals_Hist]

GO
use [NAIS_Ejendals]

GO
USE [NAIS_Ejendals_Hist]
GO
CREATE USER [NAVETTI\svc_ejendals] FOR LOGIN [NAVETTI\svc_ejendals]
GO
USE [NAIS_Ejendals_Hist]
GO
ALTER USER [NAVETTI\svc_ejendals] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [NAIS_Ejendals_Hist]
GO
ALTER ROLE [db_owner] ADD MEMBER [NAVETTI\svc_ejendals]
GO
use [NBNEjendals]

GO
use [NAIS_Ejendals_Hist]

GO
USE [NBNEjendals]
GO
CREATE USER [NAVETTI\svc_ejendals] FOR LOGIN [NAVETTI\svc_ejendals]
GO
USE [NBNEjendals]
GO
ALTER USER [NAVETTI\svc_ejendals] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [NBNEjendals]
GO
ALTER ROLE [db_owner] ADD MEMBER [NAVETTI\svc_ejendals]
GO