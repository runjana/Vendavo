use work;

    CREATE TABLE ALLFILENAMES(WHICHPATH VARCHAR(255),WHICHFILE varchar(255))
	
    --some variables
    declare @filename varchar(255),
            @path     varchar(255),
            @sql      varchar(8000),
            @cmd      varchar(1000)
create table temps (col1 varchar(max))

    --get the list of files to process:
    SET @path = 'D:\data\Data\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null


    --cursor loop
    declare c1 cursor for SELECT WHICHPATH,WHICHFILE FROM ALLFILENAMES where WHICHFILE like '%.txt%'
    open c1
    fetch next from c1 into @path,@filename
    While @@fetch_status <> -1
      begin
      --bulk insert won't take a variable name, so make a sql and execute it instead:
       set @sql = 'BULK INSERT temps FROM ''' + @path + @filename + ''' '
           + '     WITH ( 
                   FIELDTERMINATOR = '' '', 
                   ROWTERMINATOR = ''\n'', 
                   FIRSTROW = 2 
                ) '
    print @sql
    exec (@sql)

      fetch next from c1 into @path,@filename
      end
    close c1
    deallocate c1

	
	select * from temps

	drop table ALLFILENAMES
	

------openairhelp@vendavo.com