
--Monitoring Days
SELECT MIN(CaptureDate), MAX(CaptureDate) FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
--2016-04-21 17:41:01.457	2016-05-20 09:57:10.933

--This COUNTER tracks how many times a second that the Lazy Writer process is moving dirty pages from the buffer to disk
-- should be < 20, max: 1715  the numbers are very small - no need of intervention
--THERE are only 14 rec > 20
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Lazy writes/sec%'
and value <> 0
and Value > 20
ORDER BY CaptureDate DESC

--Number of physical database page reads issued. 80 – 90 per second is normal, anything that is above indicates indexing or memory constraint.
--should be < 90 - max 36 275.00 
--there are 226 over 90% from 9645
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Page reads/sec%'
--and value > 90
ORDER BY value DESC

--Number of physical database page writes issued. 80 – 90 per second is normal, anything more we need to check the lazy writer/sec and checkpoint COUNTERs, 
--if these [COUNTER]s are also relatively high then, it’s memory constraint.
--should be < 90
--there are 256 > 90, from 9645
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Page writes/sec%'
--and value > 90
ORDER BY CaptureDate DESC

--Indicates the number of requests per second that had to wait for a free page should be < 2
--there are 2 only records
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Free list stalls/sec%'
and value > 2
ORDER BY CaptureDate DESC

--Each connection is going to tie up some amount of memory, so more connections more memory tied up. 64 bit large memory may not be anything to worry about
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%User Connections%'
ORDER BY CaptureDate DESC

--should be low
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Lock Waits/sec%'
ORDER BY CaptureDate desc --value DESC

--max 22 
SELECT max(value) FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Lock Waits/sec%'

--frequency of deadlocking  - 0 (no deadlocks)
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Number of Deadlocks/sec%'
and value > 1
ORDER BY CaptureDate DESC

-- max:3297
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Transactions/sec%'
ORDER BY CaptureDate DESC

--If this number is significantly higher than your baseline, the performance of your application may be slow - 
--1607.10 - it is low
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Full Scans/sec%'
order by Value desc

--The Total Server Memory is the current amount of memory that SQL Server is using - 12 285 272 max
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Total Server Memory (KB)%'
ORDER BY CaptureDate DESC

--Total Server Memory should approximate Target Server Memory - 12 288 000 max
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Target Server Memory (KB)%'
ORDER BY CaptureDate DESC

--over 1000 batch requests per second indicates a very busy SQL Server (depending of the hardware) 
-- max 1815.70
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Batch Requests/sec%'
ORDER BY value DESC

-- < 20 per 100 Batch Requests/Sec
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Page Splits/sec%'
and Value > 20
ORDER BY Value DESC 
--33 records > 20
--max 487.70

---- < 10% of the number of Batch Requests/Sec - 529
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%SQL Compilations/sec%'
ORDER BY Value DESC

--< 10% of the number of SQL Compilations/sec - 3.80
-- 7 records > 10, max 38.40
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%SQL Re-Compilations/sec%'
and Value > 10
ORDER BY value DESC

-- < 10 - This is the number of latch requests that could not be granted immediately. In other words, these are the amount of latches, in a one second period that had to wait.
--max 1954.30, ima 7584 > 10 (sto e golem %) (ova da se vidi)
SELECT * FROM [Monitoring].[PerformanceCounters] WITH (NOLOCK)
WHERE [COUNTER] like '%Latch Waits/sec%'
and Value > 10 
ORDER BY Value DESC


select * from [Monitoring].[FileInfo]
--where LogicalFileName = 'WSS_Content_Filip_II_log'
order by CaptureDate desc
